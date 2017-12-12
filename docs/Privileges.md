# Getting started

1. [Installation](Getting_started.md)
2. [Database setup and management](Database.md)
3. [Getting initial admin priveleges](Privileges.md)
4. Customization


## Getting initial admin priveleges

Once we are done with the istallation and we have our application running, we might want to have an access to its' web admin interface.

After logging in for the first time, click on your nickname and press "Profile" in a dropdown menu.

You will be taken to your profile page now. Copy your user ID from the url - it looks like `/users/XXXX`. 

Open up the rails console:

`rails c`

Grab the user by ID:

`user = User.find(XXXX)`

and then grant the priveleges:

`user.grant(:edit, :permissions)`

You can now use the admin interface (`/admin`). You don't need to do this for other admins - you can grant all the privileges using the web interface now.