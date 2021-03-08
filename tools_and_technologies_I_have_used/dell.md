# Raghav Bhat - Dell

**DevOps architect**
I was the lead DevOps engineer in Dell for one of the new infra structure as a service product. 
I was leading the operation for the build and release team from Bangalore. 

We were consuming many third party open source products like kubernetes, ansible etc, build micro services. All the codes were preserved in GitHub. Using a CI tool called Concourse, we were building the micro services and storing the docker images in the Jfrog artifactory.

I was maintaining internal yum repository and pypi mirror to eliminate any unwanted download of any package from the internet. 
We were using packer to build the machine image. Using ansible workflows, we were downloading all the software needed, packages, firmware files, iso images, docker images inside the machine image which used to create a k8s cluster which later used to create the IaaS product when deployed on to the vcenter. 

Since the project had more than 30 plus repositories and tracking what change that went inside the each build was difficult. Hence I created a Django based release dashboard. It was integrated with concourse. It had all the details like what build is latest, what changes it has (in the form of html changelog), what is the next build expected, how many merge requests are pending, which build has to be deployed in which pod, what is the status of the testing, what are the new bugs reported etc. 

This end to end continuous integration and continuous delivery pipeline driven by django based release dashboard helped whole developer community and management team. 

Also I wrote multiple github API based automation for auto merge of branches, auto branch creation and auto branch protection updates. 

Handled complex integration of different modules into the build systems one by one. Also did set up machine monitoring, health check reports, release management, artifactory cleanup and other automation. 

Designed few infrastructure creation using terraform which were needed for release activities. 

I was handling sprint planning, scrum meetings and assigning tasks to the team in the Bangalore. 


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
-  android based product and open source integration [ Rating 4/10 ]
-  Leading the CI CD architecture implementation [ Rating 10/10]
-  Mentoring [ Rating 10/10 ]
-  Git [ Rating 8/10]

New addition:
- Docker [ Rating 8/10 ]
- Kubernetes [ Rating 6/10] 
- Scrum master and spring planning [ Rating 8/10]
- Vcenter and virtualization [ Rating 7/10 ]
- Virtual box [ Rating 7/10 ]
- Packer [ Rating 6/10 ]
- Ansible [ Rating 6/10 ]
- Jfrog Artifactory [ Rating 7/10 ]
- Concourse [ Rating 8/10 ]
- Terraform [ Rating 4/10 ]
- GitHub [ Rating 8/10 ]
- Create and maintain yum repo [ Rating 7/10 ]
- Maintain internal pypi mirror [ Rating 10/10 ]
