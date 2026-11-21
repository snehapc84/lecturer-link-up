# Lecturer Link Up

Create a Fully Functional College Lecturer Finder Website – "Lecturer Connect"

Build a modern, elegant and fully functional college website called Lecturer Connect.

The main purpose of this website is to help students easily find lecturers, check their availability and view their weekly timetables without wasting time searching for them around the college.

The website should have two separate login systems: Student Login and Lecturer Login.

1. DESIGN AND COLOUR THEME

Use the uploaded "Ice & Butter" colour palette as the main design inspiration.

The website must follow these exact colours:

Deep Navy: #2F4860

Clean White: #FFFFFF

Soft Cobalt: #7DA7D9

Butter Yellow: #FFF7CC

Ice Blue: #DCEEFF

Design instructions:

Use Ice Blue and Clean White as the main backgrounds.

Use Deep Navy for headings, navigation bars, important text and buttons.

Use Soft Cobalt for highlights, secondary buttons, icons and interactive elements.

Use Butter Yellow for subtle highlights, notification backgrounds and special accents.

Maintain good contrast and readability.

Use rounded cards, smooth corners, subtle shadows and clean layouts.

Use elegant typography and simple educational icons.

Keep the website minimal, aesthetic, professional and visually consistent.

Avoid bright neon colours, excessive gradients and cluttered layouts.

Use subtle animations and smooth transitions.

Make the website fully responsive for laptops, desktops, tablets and mobile phones.

The website should have a soft, calm and welcoming college aesthetic.

2. HOME PAGE

Create an attractive landing page containing:

Website name and logo: Lecturer Connect.

Welcome heading: "Find Your Lecturer. Connect at the Right Time."

Short description explaining the purpose of the website.

Two prominent login cards:

Student Login

Lecturer Login

Suitable illustrations or icons related to college students and lecturers.

Both login cards must navigate to their respective login pages.

3. STUDENT LOGIN

Create a separate student login page.

Login form should contain:

Student Name

Phone Number

Login Button

After successful login, redirect the student to the Student Dashboard.

Use name and phone number-based login for the initial prototype, with the option to integrate secure college authentication or OTP later.

4. STUDENT DASHBOARD

Display a personalised welcome message:

"Welcome, [Student Name]"

The dashboard should contain:

A. LECTURER DIRECTORY

Display all registered lecturers in attractive profile cards.

Each card should include:

Lecturer profile picture or avatar.

Lecturer name.

Department.

Designation.

Current availability status.

B. SEARCH FUNCTIONALITY

Add a search bar that allows students to search lecturers by:

Lecturer name.

Department.

C. LECTURER PROFILE

When a student clicks on a lecturer's profile, display:

Profile picture.

Lecturer name.

Department.

Designation.

Current availability status.

Weekly timetable.

Last updated time.

D. WEEKLY TIMETABLE

Display the lecturer's timetable in an organised weekly format.

Include:

Day.

Starting time.

Ending time.

Subject.

Classroom or laboratory.

Make the timetable easy to read and understand.

E. AVAILABILITY STATUS

Display three clearly distinguishable statuses:

AVAILABLE – Lecturer is free to meet students.

BUSY – Lecturer is currently occupied.

ABSENT – Lecturer is not present.

Use appropriate visual indicators:

Green for Available.

Yellow or Orange for Busy.

Red for Absent.

These status colours should complement the Ice & Butter theme without disturbing its overall appearance.

All changes made by lecturers must automatically reflect in the student dashboard.

5. LECTURER LOGIN

Create a separate lecturer login page.

Login form should contain:

Lecturer Name.

Phone Number.

Login Button.

After successful login, redirect the lecturer to their personal dashboard.

Lecturers should only be able to manage their own profiles, availability and timetables.

Use secure authentication architecture that can support college-authorised accounts in the future.

6. LECTURER DASHBOARD

Create a separate and easy-to-use dashboard for lecturers.

Display:

Welcome message with lecturer's name.

Profile information.

Current availability.

Timetable management section.

A. AVAILABILITY MANAGEMENT

Provide three large and easily accessible buttons:

AVAILABLE

BUSY

ABSENT

When a lecturer clicks one of these options, immediately update their availability status.

Functionality:

Available: Students can see that the lecturer is available.

Busy: Students can see that the lecturer is currently occupied.

Absent: Students can see that the lecturer is absent.

Allow lecturers to optionally specify the duration of their Busy or Available status.

For example: Busy until 12:30 PM.

Display the last updated time.

B. TIMETABLE MANAGEMENT

Provide a simple timetable editor.

Lecturers should be able to:

Add new timetable entries.

Edit existing entries.

Delete timetable entries.

View their complete weekly timetable.

Each timetable entry should include:

Day of the week.

Start time.

End time.

Subject name.

Classroom or laboratory.

Make timetable editing simple and convenient.

Changes should be saved automatically or through a clear Save Changes button and reflected in the student dashboard.

Lecturers should not have to recreate their entire timetable when making a small change.

7. DATABASE AND FUNCTIONALITY

The website must be fully functional, not just a visual prototype.

Implement:

Separate student and lecturer login systems.

Lecturer profile management.

Search and filter functionality.

Availability status updates.

Timetable creation, editing and deletion.

Automatic synchronisation of lecturer updates with student views.

Persistent database storage.

Logout functionality.

Form validation.

Helpful error messages.

Appropriate authentication and access permissions.

Use Supabase or Firebase for database and authentication if supported.

Students must not be allowed to edit lecturer information or timetables.

Do not display lecturers' private phone numbers publicly.

Do not include any current physical location tracking or location update feature.

8. SAMPLE DATA

Add a few fictional sample lecturer profiles and sample weekly timetables for demonstration.

Use realistic engineering college departments and subjects.

Clearly identify demonstration accounts and allow the sample information to be edited or replaced.

9. FINAL EXPECTATIONS

The final website must:

Have a beautiful Ice & Butter themed interface.

Have a complete home page.

Provide separate Student and Lecturer login options.

Have different dashboards for both users.

Allow students to search for lecturers.

Allow students to view lecturer profiles and timetables.

Allow lecturers to update their availability using Available, Busy and Absent buttons.

Allow lecturers to add, edit and delete timetable entries.

Reflect all changes across both dashboards.

Work properly on desktop and mobile devices.

IMPORTANT: Focus equally on design and actual functionality. Do not create buttons that only look interactive. Every button, form, search bar, login option and timetable control must perform its intended action.

The final result should look like a polished, professional college management website with the Ice & Butter aesthetic.

This project was built with [Lovable](https://lovable.dev).

**Live app**: https://lecturer-link-up.lovable.app

## Build with Lovable

Continue developing this project in the [Lovable editor](https://lovable.dev/projects/dc13aaf2-1a64-58e3-8c53-816c001bba22).

- **Ship faster**: describe what you want to build and Lovable handles the code.
- **Stay in sync**: every change made in Lovable is committed straight to this repository.
- **Full ownership**: this code is yours. Push to `main` on GitHub and your changes sync back into Lovable, ready for your next prompt.

## Development

Prefer working locally? You need Node.js and npm — [install with nvm](https://github.com/nvm-sh/nvm#installing-and-updating).

```sh
git clone <this-repository-url>
cd <repository-name>
npm i
npm run dev
```
