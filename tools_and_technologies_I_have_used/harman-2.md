# Raghav Bhat - Harman -2

**Senior release engineer**
I did re-join Harman. Most of the responsibilities were similar to first [stint](https://github.com/ragsmpl/mycodes/blob/master/tools_and_technologies_I_have_used/harman.md)

There was a system in place to carryout weekly releases. We were collecting commits to be integrated as part of excel sheets. We had perl script which reads the commit IDs and integrate them from development branch to release branch. 

But I found this has to be changed, because maintaining excel sheet was challenging. Since I learnt Django and Python from my previous job, I thought of making use of it to improve the system.

I created request for integration dashboard. It had html based web page as front end, django based msql as a backend. I introduced all the gating checks in the form using python in views.py. It was a great success, as developer need not create excel sheets anymore. Management was able to see all the integration activities in a single place, status of each commit, label it was part of. All our report generation, build scripts were moved to python with the help of team. I was the architect of whole CI CD system with this new dashboard and drove the activity to completion within 6 months. 

Then we were asked to handle android based product release. Again we upgraded our request for integration tool to adapt the change, all our builds were automated using Jenkins and Python. 

We were responsible for creating and maintaining aws instances in which we used to create home directories for each developers, so that they can have similar and high end systems for their development activities. 

On demand instances were attached to our Jenkins masters. Based on demand, we used to auto scale up number of instances needed to serve our releases. 

Being the senior engineer I was mentoring the junior members and guiding them to implement the process improvement.
## What did I learn?

It was very good learning experience. I added below tools and technologies into my knowledge library:

-   Shell scripting [ Rating 7/10]
-   make build system[Rating 6/10]
-   Perforce (Version control, branching, merging) [Rating 9/10]
-   Hudson/Jenkins/build central [Rating 9/10]
-   Release management [ Rating 9/10]
-   Bug tracking and management [ Rating 10/10]
-   Linux fundamentals [ Rating 8/10]
-   Managing infra structure for the build [ Rating 9/10]
-   build central/Cruice control [Rating 9/10]
-   jamfile based system [Rating 5/10]
-   Perl/Java scripting [Rating 6/10]
-   Software integration [Rating 8/10]
-   On demand release [Rating 10/10]
-   Collaboration and communication skills [Rating 8/10]
-   Taking ownership of whole patch release process and execute. [ Rating 8/10]
-   Handle all the escalations and on demand releases [ Rating 8/10] 
-   Python [Rating 8/10]
-   Django [ Rating 8/10]
-   SVN [ Rating 8/10]
-   CD CD architecture [ Rating 8/10]
-   Git [ Rating 6/10 ]

New addition:
- android based product and open source integration [ Rating 4/10 ]
- Leading the CI CD architecture implementation [ Rating 8/10]
- Mentoring [ Rating 6/10 ]
- Gerrit [ Rating 6/10 ]
- 
