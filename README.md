## Instructions:

1. Identify the dimensions from each dimension table 

You'll notice in bed_type there are only three variables: bed_id, bed_code, and bed_desc.
Consider which of these is a fact if any and which is a dimension. Note that the PK qualifies as a dimension.

For the business table, pay attention to the differences between a fact and a dimension variable as we discussed in class. In this table there are only three dimensions to select. See if you can correctly identify which ones they are (again the PK can be counted as one dimension).

2. Identify the fact variables from the single fact table 

Consider what type of variable would be a fact vs. a dimension and select three of those from the bed_fact table. Be aware, it is likely that some variables in a fact table are dimensions, for example a foreign key or anything of that sort is a dimension even if it's listed in the fact table.

3. Create a new schema in MySQL Workbench and add the downloaded .csv files as tables.

4. Use ALTER TABLE SQL commands OR use MySQL Workbench to specify the relationships between tables.

i) Navigate to the Table:

In the Navigator pane on the left, locate your database and the table you want to modify.
Right-click the table and choose Alter Table.

ii) Modify Keys:

In the Alter Table dialog, go to the Indexes tab to manage primary keys and other indexes.
You can add new indexes or primary keys by:
Adding a Primary Key:
Click on the column in the Columns tab and check the PK checkbox for the column you want as a primary key.
Adding a Foreign Key:
Switch to the Foreign Keys tab.
Click the Add button.
Specify the name, reference table, and reference column(s).
Save Changes:
Once you've made your changes, click Apply.
NOTE: Errors are to be expected in this phase. Read the error code and try to understand it. Then Google it. Don't hesitate to reach out to me for help/hints at how to do this correctly.

5. Use "Reverse Engineering Wizard" to create an ERD of a Star Schema using MySQL Workbench

Include both the data tables of interest and the appropriate joins between the tables that can be used to answer the questions.
Use MySQL to draw the star schema.
Be sure to label the fact table and dimension tables accordingly! You can add a text box above the tables in MySQL Workbench if you need to.
File>Export your Star Schema as a .png image file and paste it into your .pdf document.
6a. Analysis for leadership 

Identify which hospitals have an Intensive Care Unit (ICU bed_id = 4) bed or a Surgical Intensive Care Unit (SICU bed_id = 15) bed or both.
Create three summary reports that show the following:
License beds: List of Top 10 Hospitals ordered descending by the total ICU or SICU license beds.
Include just two variables:
Hospital name (business_name)
The total license bed count from above as one summary fact
But include only 10 rows in your output table.
Do the same thing for Census beds. List of Top 10 Hospitals ordered by total ICU or SICU census beds. Include just two variables: hospital name (business_name) and the total census beds from above, as one summary fact. Include only 10 rows again.
Do the same thing for Staffed beds. List of Top 10 Hospitals ordered by the total ICU or SICU staffed beds. Include just two variables: hospital name (business_name) and the sum of staffed beds from above, as one summary fact. Include only 10 rows again.
6b. Interpretation of Findings 

Based on your results from step 4a, discuss your insights from the data summary that you want to bring to the attention of leadership.

For example:

What are the top one or two hospitals per list based on bed volume?
Are there any hospitals that appear on multiple lists? They might make good candidates for the intervention pilot program.
7a. Drill down investigation 

Leadership is also interested in hospitals that have sufficient volume of both ICU and SICU beds, as opposed to either type of bed that you developed in step 4a.

Conduct the same investigation as you did for 4a and list the same output of top 10 hospitals by descending bed volume, only this time select only those top 10 hospitals that have both kinds of ICU and SICU beds, i.e. only hospitals that have at least 1 ICU bed and at least 1 SICU bed.
Conduct separate data investigations for census beds, license beds, and staffed beds (like step 4a).
7b. Final recommendation 

Based on your analyses in step 4a and 5a, state your final recommendation here for leadership as to which hospitals are the best candidates for their pilot intervention program. Remember, leadership has stated they are only interested in one or two hospitals for their pilot sites so it’s best to tailor your recommendation to their business needs and avoid unnecessary details that might confuse them.

Identify your hospitals and briefly explain why you chose them.
