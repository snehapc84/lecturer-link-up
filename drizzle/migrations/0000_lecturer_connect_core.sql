
CREATE TYPE public.app_role AS ENUM ('student', 'lecturer');
CREATE TYPE public.availability_status AS ENUM ('available', 'busy', 'absent');

-- Roles
CREATE TABLE public.user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role public.app_role NOT NULL,
  UNIQUE (user_id, role)
);
GRANT SELECT ON public.user_roles TO authenticated;
GRANT ALL ON public.user_roles TO service_role;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can read their own roles" ON public.user_roles
  FOR SELECT TO authenticated USING (user_id = auth.uid());

CREATE OR REPLACE FUNCTION public.has_role(_user_id uuid, _role public.app_role)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role = _role)
$$;

-- Lecturers
CREATE TABLE public.lecturers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid UNIQUE,
  name text NOT NULL CHECK (char_length(name) BETWEEN 2 AND 100),
  department text NOT NULL CHECK (char_length(department) BETWEEN 2 AND 100),
  designation text NOT NULL CHECK (char_length(designation) BETWEEN 2 AND 100),
  status public.availability_status NOT NULL DEFAULT 'available',
  status_until timestamptz,
  status_note text CHECK (status_note IS NULL OR char_length(status_note) <= 140),
  status_updated_at timestamptz NOT NULL DEFAULT now(),
  timetable_updated_at timestamptz NOT NULL DEFAULT now(),
  is_demo boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.lecturers TO authenticated;
GRANT UPDATE (name, department, designation, status, status_until, status_note) ON public.lecturers TO authenticated;
GRANT ALL ON public.lecturers TO service_role;
ALTER TABLE public.lecturers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Students and lecturers can view lecturers" ON public.lecturers
  FOR SELECT TO authenticated
  USING (public.has_role(auth.uid(), 'student') OR public.has_role(auth.uid(), 'lecturer'));
CREATE POLICY "Lecturers update own profile" ON public.lecturers
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid() AND public.has_role(auth.uid(), 'lecturer'))
  WITH CHECK (user_id = auth.uid());

CREATE OR REPLACE FUNCTION public.lecturers_touch()
RETURNS trigger LANGUAGE plpgsql SET search_path = public AS $$
BEGIN
  NEW.updated_at := now();
  IF NEW.status IS DISTINCT FROM OLD.status
     OR NEW.status_until IS DISTINCT FROM OLD.status_until
     OR NEW.status_note IS DISTINCT FROM OLD.status_note THEN
    NEW.status_updated_at := now();
  END IF;
  IF NEW.status = 'absent' THEN
    NEW.status_until := NULL;
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER lecturers_touch BEFORE UPDATE ON public.lecturers
  FOR EACH ROW EXECUTE FUNCTION public.lecturers_touch();

-- Private lecturer phone numbers (service role only)
CREATE TABLE public.lecturer_contacts (
  lecturer_id uuid PRIMARY KEY REFERENCES public.lecturers(id) ON DELETE CASCADE,
  phone text NOT NULL UNIQUE CHECK (phone ~ '^[0-9]{10,15}$')
);
GRANT ALL ON public.lecturer_contacts TO service_role;
ALTER TABLE public.lecturer_contacts ENABLE ROW LEVEL SECURITY;

-- Students
CREATE TABLE public.students (
  user_id uuid PRIMARY KEY,
  name text NOT NULL CHECK (char_length(name) BETWEEN 2 AND 100),
  phone text NOT NULL UNIQUE CHECK (phone ~ '^[0-9]{10,15}$'),
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.students TO authenticated;
GRANT ALL ON public.students TO service_role;
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Students read own record" ON public.students
  FOR SELECT TO authenticated USING (user_id = auth.uid());

-- Timetable
CREATE TABLE public.timetable_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lecturer_id uuid NOT NULL REFERENCES public.lecturers(id) ON DELETE CASCADE,
  day_of_week smallint NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
  start_time time NOT NULL,
  end_time time NOT NULL,
  subject text NOT NULL CHECK (char_length(subject) BETWEEN 1 AND 120),
  room text NOT NULL CHECK (char_length(room) BETWEEN 1 AND 60),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (end_time > start_time)
);
CREATE INDEX timetable_entries_lecturer_idx ON public.timetable_entries (lecturer_id, day_of_week, start_time);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.timetable_entries TO authenticated;
GRANT ALL ON public.timetable_entries TO service_role;
ALTER TABLE public.timetable_entries ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Students and lecturers can view timetables" ON public.timetable_entries
  FOR SELECT TO authenticated
  USING (public.has_role(auth.uid(), 'student') OR public.has_role(auth.uid(), 'lecturer'));
CREATE POLICY "Lecturers add own entries" ON public.timetable_entries
  FOR INSERT TO authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM public.lecturers l WHERE l.id = lecturer_id AND l.user_id = auth.uid()));
CREATE POLICY "Lecturers edit own entries" ON public.timetable_entries
  FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.lecturers l WHERE l.id = lecturer_id AND l.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.lecturers l WHERE l.id = lecturer_id AND l.user_id = auth.uid()));
CREATE POLICY "Lecturers delete own entries" ON public.timetable_entries
  FOR DELETE TO authenticated
  USING (EXISTS (SELECT 1 FROM public.lecturers l WHERE l.id = lecturer_id AND l.user_id = auth.uid()));

CREATE OR REPLACE FUNCTION public.timetable_validate()
RETURNS trigger LANGUAGE plpgsql SET search_path = public AS $$
BEGIN
  NEW.updated_at := now();
  IF EXISTS (
    SELECT 1 FROM public.timetable_entries t
    WHERE t.lecturer_id = NEW.lecturer_id
      AND t.day_of_week = NEW.day_of_week
      AND t.id <> NEW.id
      AND t.start_time < NEW.end_time
      AND NEW.start_time < t.end_time
  ) THEN
    RAISE EXCEPTION 'This time overlaps with another class on the same day.' USING ERRCODE = 'P0001';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER timetable_validate BEFORE INSERT OR UPDATE ON public.timetable_entries
  FOR EACH ROW EXECUTE FUNCTION public.timetable_validate();

CREATE OR REPLACE FUNCTION public.timetable_touch_lecturer()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  UPDATE public.lecturers SET timetable_updated_at = now()
  WHERE id = COALESCE(NEW.lecturer_id, OLD.lecturer_id);
  RETURN NULL;
END $$;
CREATE TRIGGER timetable_touch_lecturer AFTER INSERT OR UPDATE OR DELETE ON public.timetable_entries
  FOR EACH ROW EXECUTE FUNCTION public.timetable_touch_lecturer();

-- Realtime
ALTER TABLE public.lecturers REPLICA IDENTITY FULL;
ALTER TABLE public.timetable_entries REPLICA IDENTITY FULL;
ALTER PUBLICATION supabase_realtime ADD TABLE public.lecturers;
ALTER PUBLICATION supabase_realtime ADD TABLE public.timetable_entries;

-- Demo data (fictional)
INSERT INTO public.lecturers (id, name, department, designation, status, status_note, is_demo) VALUES
  ('11111111-0000-4000-8000-000000000001', 'Dr. Ananya Rao', 'Computer Science & Engineering', 'Associate Professor', 'available', 'In staff room B-204', true),
  ('11111111-0000-4000-8000-000000000002', 'Prof. Vikram Menon', 'Electronics & Communication', 'Professor & HoD', 'busy', 'Department meeting', true),
  ('11111111-0000-4000-8000-000000000003', 'Dr. Priya Shah', 'Mechanical Engineering', 'Assistant Professor', 'available', NULL, true),
  ('11111111-0000-4000-8000-000000000004', 'Mr. Arjun Nair', 'Civil Engineering', 'Assistant Professor', 'absent', 'On leave today', true),
  ('11111111-0000-4000-8000-000000000005', 'Dr. Kavitha Iyer', 'Electrical & Electronics', 'Associate Professor', 'busy', 'Lab evaluation', true),
  ('11111111-0000-4000-8000-000000000006', 'Ms. Sneha Kulkarni', 'Information Technology', 'Assistant Professor', 'available', NULL, true);

INSERT INTO public.lecturer_contacts (lecturer_id, phone) VALUES
  ('11111111-0000-4000-8000-000000000001', '9000000001'),
  ('11111111-0000-4000-8000-000000000002', '9000000002'),
  ('11111111-0000-4000-8000-000000000003', '9000000003'),
  ('11111111-0000-4000-8000-000000000004', '9000000004'),
  ('11111111-0000-4000-8000-000000000005', '9000000005'),
  ('11111111-0000-4000-8000-000000000006', '9000000006');

INSERT INTO public.timetable_entries (lecturer_id, day_of_week, start_time, end_time, subject, room) VALUES
  ('11111111-0000-4000-8000-000000000001', 1, '09:00', '10:00', 'Data Structures', 'CSE-101'),
  ('11111111-0000-4000-8000-000000000001', 1, '11:15', '12:15', 'Operating Systems', 'CSE-204'),
  ('11111111-0000-4000-8000-000000000001', 2, '10:00', '12:00', 'Data Structures Lab', 'Computer Lab 2'),
  ('11111111-0000-4000-8000-000000000001', 3, '09:00', '10:00', 'Data Structures', 'CSE-101'),
  ('11111111-0000-4000-8000-000000000001', 4, '14:00', '15:00', 'Operating Systems', 'CSE-204'),
  ('11111111-0000-4000-8000-000000000001', 5, '11:15', '12:15', 'Design & Analysis of Algorithms', 'CSE-110'),
  ('11111111-0000-4000-8000-000000000002', 1, '10:00', '11:00', 'Digital Signal Processing', 'ECE-301'),
  ('11111111-0000-4000-8000-000000000002', 2, '09:00', '10:00', 'VLSI Design', 'ECE-305'),
  ('11111111-0000-4000-8000-000000000002', 3, '14:00', '16:00', 'Microprocessors Lab', 'Electronics Lab 1'),
  ('11111111-0000-4000-8000-000000000002', 5, '10:00', '11:00', 'Digital Signal Processing', 'ECE-301'),
  ('11111111-0000-4000-8000-000000000003', 1, '13:00', '14:00', 'Thermodynamics', 'ME-102'),
  ('11111111-0000-4000-8000-000000000003', 2, '11:15', '12:15', 'Fluid Mechanics', 'ME-108'),
  ('11111111-0000-4000-8000-000000000003', 4, '09:00', '11:00', 'Workshop Practice', 'Mechanical Workshop'),
  ('11111111-0000-4000-8000-000000000003', 6, '10:00', '11:00', 'Thermodynamics', 'ME-102'),
  ('11111111-0000-4000-8000-000000000004', 1, '09:00', '10:00', 'Structural Analysis', 'CE-201'),
  ('11111111-0000-4000-8000-000000000004', 3, '11:15', '12:15', 'Surveying', 'CE-105'),
  ('11111111-0000-4000-8000-000000000004', 4, '14:00', '16:00', 'Surveying Field Lab', 'Survey Lab'),
  ('11111111-0000-4000-8000-000000000005', 2, '13:00', '14:00', 'Power Systems', 'EEE-210'),
  ('11111111-0000-4000-8000-000000000005', 3, '10:00', '11:00', 'Electrical Machines', 'EEE-204'),
  ('11111111-0000-4000-8000-000000000005', 5, '14:00', '16:00', 'Machines Lab', 'Electrical Lab'),
  ('11111111-0000-4000-8000-000000000006', 1, '14:00', '15:00', 'Web Technologies', 'IT-103'),
  ('11111111-0000-4000-8000-000000000006', 2, '09:00', '10:00', 'Database Management Systems', 'IT-201'),
  ('11111111-0000-4000-8000-000000000006', 4, '10:00', '12:00', 'DBMS Lab', 'Computer Lab 4'),
  ('11111111-0000-4000-8000-000000000006', 5, '09:00', '10:00', 'Web Technologies', 'IT-103');
