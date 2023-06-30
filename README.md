# Description of entire system

My social network application, "POST IT," is designed specifically for Ashesi students. It offers a range of features that allow users to create an account, log in, edit their profiles, view posts made by other users, make posts themselves, and filter posts to view unique content. In addition, users can customize their profile images and edit other fields, except for their student ID, name, email, and year group.
During the sign-up process, both the back-end and front-end of the application ensure that the year group selected by the user matches the last four digits of their student ID. This is crucial to maintain consistency and accuracy in user registration. Since an Ashesi student's year group cannot differ from the last four digits of their student ID, this check is essential. Moreover, the application checks all fields to ensure that users do not submit empty forms. Each text field must be completed appropriately, and the application only accepts eight-digit numerical values for the student ID field.

Furthermore, the application ensures that the last four digits of the student ID correspond to a valid year by checking that the value is not less than 2002, the year Ashesi was established. The application also implements session management, which allows users to log in and retrieve their unique details, ensuring their privacy and security. Finally, users cannot make posts without creating an account, which provides an extra layer of security.

In conclusion, "POST IT" is a comprehensive social network application with several checks and features built-in to ensure user accuracy, security, and privacy.

# The link to the api: 
https://us-central1-social-network-383614.cloudfunctions.net/social-network

# The link to my WebApp:
https://social-network-9cbc8.web.app/#/splash
