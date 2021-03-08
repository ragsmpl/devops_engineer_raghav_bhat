# Raghav Bhat - HCL Technologies

I did start my career as software configuration engineer. I was new to the IT and software configuration management. My first job was with HCL technologies and I was part of digital TV domain. 

**Software configuration management**
This team was responsible for end to end software configuration management. It involved responsibilities like setting up perforce servers, setting up Hudson/Jenkins pipelines, configuration of parasoft code review tool, maintaining business continuity plan and development continuity plan, setting up code review and code merge rules, build and release management, creating infrastructure for build and release, smoke testing of weekly builds, follow up and fix build breaks. 

When any new project starts, we have to plan few things first, that is where software configuration management comes into play. 
Understand the project by discussing with architect team. Below things needs to be planned:

- what is the software is all about.
- It will be written in which language and how to it will be built.
- What is the frequency of release and how it will be tested?
- How the software artifacts will be created and stored?
- Which tools can be used for code quality check. 
- Which tools can be used for version control?
- Which tool can be used to design continuous integration?
- Which type of servers we need for build and release. 
- Which tool can be used for bug reporting and tracking?

Since I was the junior most member of the team along with others, it was more of a learning in the initially. 
I learnt **linux fundemental**s, **shell scripting**, **perforce**, **setting up and installing software** in the **machines**. Once I had good understanding of the infra knowledge, I started writing scripts to monitor the build machines we were using. It used to send alerts about the health of the system.

Slowly I started understanding more about perforce and why version control system plays vital role in the software life cycle. 
I learnt below concepts in depth:
- Branch
- Merge
- code review
- conflicts
- revert
- workspace 

Having strong code management knowledge, I got the opportunity to install and manage **Hudson** (later we moved to **Jenkins**).  Initially I started looking into existing jobs in the Jenkins, how master and slave is being added, how to maintain them, why to use different slaves. 

Then I started configuring the jobs for the new projects, understanding of shell scripting and Linux fundamentals played an important role here. This is the first time I was involved in setting up **continuous integration**.

I did configuration Hudson/Jenkins for different development teams, handled build breaks, involved in ensuring weekly builds are done on time and smoke testing them by flashing on to the hardware. 

We were using two different service providers for the internet. We were using different proxies to connect to the perforce servers. We were facing network slowness issue and it impacted the perforce performance. Hence we introduced **business continuity plan/development continuity plan**. These plans needed switching of network when one service provider hit slowness issue and continuously do a **code drop** from remote server to local perforce server, so that development community could use local perforce server when we have no internet access. 

We were getting help from IT team, but there were managing different projects, hence we decided to write a piece of code to enable ourselves detecting network performance and switch proxy servers when needed.
I wrote a shell script which continuously sync a particular folder every 15 mins and we had a good performance time noted down. When sync time used to increase, we used to switch the proxy. This ensured, developers were not impacted at all when there was network issues. Perforce being centralized version control system, without internet, it was impossible to use. That is why we had set up a local perforce server, if internet is down for long time, developer could switch to intranet perforce server. 

We were managing multiple projects and hence we had multiple Hudson/Jenkins instances and it was very difficult for the management to get a overview of all the releases status at a glance. Hence I learnt HTML, javascript, css and developed a web page to integrate all the Hudson/Jenkins in one place.  This initiative was recognized by the project management and I was rewarded with live wire award for the year 2012.
## What did I learn?
It was very good learning experience. I added below tools and technologies into my knowledge library:
- Shell Scripting [Rating 6/10]
- Perforce (Version control, branching, merging) [Rating 7/10]
- Hudson/Jenkins [Rating 7/10]
- make build system[Rating 6/10]
- Release management [ Rating 6/10]
- Bug tracking and management [ Rating 7/10]
- Building dashboard [ Rating 5/10]
- Linux fundamentals [ Rating 6/10]
- Managing infra structure for the build [ Rating 6/10]
