# Raghav Bhat - Harman International

I left HCL tech and Joined Harman international for better salary. It was my first switch. I was hired as software integrator and build/release engineer.

**Software Integration/build and release**
In HCL, I handled project which was maintained by single large team. But in Harman, our team had to integrate releases from different teams and build our code and then make the releases. That is why I stated my role as software integrator and build/release engineer.

I was part of infotainment and automotive division of Harman. This we were building connectivity and infotainment portion of the product. For this code to work, we needed system binaries and other components to be integrated. Hence we used to get all needed code drops from different teams in different repositories hosted in perforce and then we ingrate them to build and release the binaries.

Project had different perforce server for source code and binaries. I was handling multiple projects for different customers. Each code is maintained in different branches. We used to make weekly releases. We were writing and maintaining all the scripts in shell and perl. 
We were using internal tool called build central and cruise control for as CI tools along with Jenkins. 
Here I learnt java coding to develop a GUI based build and release tool. Which runs perl script in the backend. Automatically takes code from development branch to release branch and other steps of integration and build. 

We were maintaining feature toggling. Some of the customer releases were maintained in the same branch, hence we were building different releases using feature toggle as features were specific to customers. 

Build binaries were pushed in to the binary perforce server. We were creating labels in both source servers and binary server with unique week ID.

We were maintaining a script to compare the binaries with respect to previous week. Only modified binaries were updated to the label. 

Then we used to run a script to segregate these binaries in system lib and bin path and creating jar file which later flashed on the hardware. We were performing smoke testing to ensure, build binaries were working as expected. 
Then this will be handed over to the testing team for the regression testing and collect the test report. 

Once we have the test report for each bug ID, we mark that bug passed or failed. 
Based on the criticality of the failure, we would release the label or deny the label for that particular week for the particular branch. 

Once we are done with the releases, we were preparing releases notes and integration reports. 

I was handling hotfixes for many releases we were supporting. In case if a customer is hitting a issue, which can not be waited for the next weekly releases would be given as hotfix. I was following up with the developer and project manager to ensure have the fix ready on time to make the release. 

We were running sonar for static code analysis and creating and assigning bugs to module owners as and when reported. 

Elvis was the bug tracking tool used and JIRA was the project management tool used. 

## What did I learn?
It was very good learning experience. I added below tools and technologies into my knowledge library:
- Shell scripting [ Rating 7/10]
- make build system[Rating 6/10]
- Perforce (Version control, branching, merging) [Rating 9/10]
- Hudson/Jenkins/build central [Rating 9/10]
- Release management [ Rating 9/10]
- Bug tracking and management [ Rating 10/10]
- Linux fundamentals [ Rating 8/10]
- Managing infra structure for the build [ Rating 9/10]

New addition:
- build central/Cruice control [Rating 9/10]
- jamfile based system [Rating 5/10]
- Perl/Java scripting [Rating  6/10]
- Software integration [Rating 8/10]
- On demand release [Rating 10/10]
