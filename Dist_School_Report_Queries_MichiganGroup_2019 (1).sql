/***********************************************
** File: Dist_School_Report_queries.sql
** Desc: Final Project - Understanding Characteristics of Elemenatary Education in India 
						 With repect to Students' Enrollments and Learning Outcomes
** Group: Michigan
** Date: 27th August 2019
************************************************/


USE districtschoolreport;


 SET SQL_SAFE_UPDATES = 0;

## Transforming proportion values into percentage values in learning_outcomes table, for comparison##
UPDATE learning_outcomes
SET 
	Reading_Nothing = Reading_Nothing*100,
    Reading_Letter = Reading_Letter*100,
    Word = Word*100,
    Std1_Para = Std1_Para*100,
    Std2_Para = Std2_Para*100,
    Arithematic_Nothing = Arithematic_Nothing*100,
    Arithematic_Number_1to9 = Arithematic_Number_1to9*100,
    Arithematic_Number_11to99 = Arithematic_Number_11to99*100,
    Arithematic_Subtraction = Arithematic_Subtraction*100,
    Arithematic_Division = Arithematic_Division*100;
    
SELECT * 
FROM learning_outcomes;

########################### Basic School Infrastructure ###########################
 
 ## Availability of Infrastructure facilities (counted as number of schools that have the facility) 
 ## within Schools, per district
 
SELECT s.Data_Year, d.District_name, f.MiddayMeal_GovtandAided as MidDayMeal_Facility, 
 f.Drinking_water, f.Electricity, f.SMC_GovtAided, f.Girls_toilet, 
 s.PrimaryS+ s.Primary_PlusS+ s.Upper_PrimaryS +s.Upper_Primary_PlusS as Total_Schools
 FROM school s, districts d, facilities_infra f
 WHERE d.District_ID = s.Districts_District_ID
 AND f.School_School_ID = s.School_ID
 ORDER BY s.Data_Year DESC;
 
## Top 10 districts by percentage of schools that have computer facility (in 2016)##

SELECT s.Data_Year, d.District_name, f.Computer as Computer_Facility, 
 s.PrimaryS+ s.Primary_PlusS+ s.Upper_PrimaryS +s.Upper_Primary_PlusS as Total_Schools,
 (f.Computer)*100/(s.PrimaryS+ s.Primary_PlusS+ s.Upper_PrimaryS +s.Upper_Primary_PlusS) as PercentSchools_WithComputer
 FROM school s, districts d, facilities_infra f
 WHERE d.District_ID = s.Districts_District_ID
 AND f.School_School_ID = s.School_ID
 AND s.Data_Year = 2016
 ORDER BY PercentSchools_WithComputer DESC
 LIMIT 10;
 
 ## Bottom 10 districts by percentage of schools that have computer facility (in 2016) 
 
 SELECT 
	s.Data_Year, d.District_name, f.Computer as Computer_Facility, 
	s.PrimaryS+ s.Primary_PlusS+ s.Upper_PrimaryS +s.Upper_Primary_PlusS as Total_Schools,
	(f.Computer)*100/(s.PrimaryS+ s.Primary_PlusS+ s.Upper_PrimaryS +s.Upper_Primary_PlusS) as PercentSchools_WithComputer
 FROM 
	school s, districts d, facilities_infra f
 WHERE d.District_ID = s.Districts_District_ID
 AND f.School_School_ID = s.School_ID
 AND s.Data_Year = 2016
 ORDER BY PercentSchools_WithComputer
 LIMIT 10;
 
 ###########################Understanding Enrollment Patterns###########################

## Enrolments by school Type  
select
	Data_Year,
	sum(PrimaryGrade_Enrol) as Total_PrimaryGrade_Enrol,
    sum(Upper_PrimaryGrade_Enrol) as Total_Upper_PrimaryGrade_Enrol,
    sum(Govt_Enrol_all) as Total_Govt_Enrol_all,
    sum(Pvt_Enrol_all) as Total_Pvt_Enrol_all,
    sum(GovtRural_Enrol_all) as Total_GovtRural_Enrol_all,
    sum(PvtRural_Enrol_all) as Total_PvtRural_Enrol_all
from
	enrol_school_type
group by Data_Year;

## Average Enrollments (Rounded off to the nearest integer) by states over 3 years  ##
select
	st.States_ID,
    st.States_name,
	ROUND(avg(es.PrimaryGrade_Enrol)) as Average_PrimaryGrade_Enrol,
    ROUND(avg(es.Upper_PrimaryGrade_Enrol)) as Average_Upper_PrimaryGrade_Enrol,
    ROUND(avg(es.Govt_Enrol_all)) as Average_Govt_Enrol_all,
    ROUND(avg(es.Pvt_Enrol_all)) as Average_Pvt_Enrol_all,
    ROUND(avg(es.GovtRural_Enrol_all)) as Average_GovtRural_Enrol_all,
    ROUND(avg(es.PvtRural_Enrol_all)) as Average_PvtRural_Enrol_all,
    ROUND(avg(es.PrimaryGrade_Enrol + es.Upper_PrimaryGrade_Enrol)) as Average_Total_Enrollment
from
	enrol_school_type es
		Inner join
	school s on es.School_School_ID=s.School_ID
		Inner join
	districts d on s.Districts_District_ID=d.District_ID
		inner join
	states st on d.States_States_ID=st.States_ID
group by States_ID
order by Average_Total_Enrollment DESC
LIMIT 10;


## Relation between Midday Meals and Total Enrollment (District wise)

 SELECT 
	s.Data_Year, d.District_name, f.MiddayMeal_GovtandAided as MidDayMeal_Facility, 
	e.PrimaryGrade_Enrol + e.Upper_PrimaryGrade_Enrol as Total_Enrollment
 FROM 
	enrol_school_type e, school s, districts d, facilities_infra f
 WHERE d.District_ID = s.Districts_District_ID
 AND f.School_School_ID = s.School_ID
 AND e.School_School_ID = s.School_ID
 ORDER BY s.Data_Year DESC;
 
 ##Ranking Districts by Total Enrollment (year-wise) against number of schools that provide  Midday Meals 
 ##Top and Bottom 5 districts
 
 SELECT a.*
 FROM(
	SELECT a1.*
	FROM(
	SELECT 
		s.Data_Year, d.District_name, f.MiddayMeal_GovtandAided as MidDayMeal_Facility, 
		e.PrimaryGrade_Enrol + e.Upper_PrimaryGrade_Enrol as Total_Enrollment
	FROM 
		enrol_school_type e, school s, districts d, facilities_infra f
	WHERE d.District_ID = s.Districts_District_ID
	AND f.School_School_ID = s.School_ID
	AND e.School_School_ID = s.School_ID
	ORDER BY Total_Enrollment DESC
	LIMIT 5) a1
    UNION
    SELECT a2.*
	FROM(
	SELECT 
		s.Data_Year, d.District_name, f.MiddayMeal_GovtandAided as MidDayMeal_Facility, 
		e.PrimaryGrade_Enrol + e.Upper_PrimaryGrade_Enrol as Total_Enrollment
	FROM 
		enrol_school_type e, school s, districts d, facilities_infra f
	WHERE d.District_ID = s.Districts_District_ID
	AND f.School_School_ID = s.School_ID
	AND e.School_School_ID = s.School_ID
	ORDER BY Total_Enrollment 
	LIMIT 5) a2
    ) a;
 
 ## 1e) enrolments by states for 2014 ##
select
	st.States_ID,
    es.Data_Year,
    st.States_name,
	sum(es.PrimaryGrade_Enrol) as Total_PrimaryGrade_Enrol,
    sum(es.Upper_PrimaryGrade_Enrol) as Total_Upper_PrimaryGrade_Enrol,
    sum(es.Govt_Enrol_all) as Total_Govt_Enrol_all,
    sum(es.Pvt_Enrol_all) as Total_Pvt_Enrol_all,
    sum(es.GovtRural_Enrol_all) as Total_GovtRural_Enrol_all,
    sum(es.PvtRural_Enrol_all) as Total_PvtRural_Enrol_all
from
	enrol_school_type es
		Inner join
	school s on es.School_School_ID=s.School_ID
		Inner join
	districts d on s.Districts_District_ID=d.District_ID
		inner join
	states st on d.States_States_ID=st.States_ID
where
	es.Data_Year='2014' 
group by States_ID
order by States_ID;


### enrolments by states for 2015 ##
select
	st.States_ID,
    es.Data_Year,
    st.States_name,
	sum(es.PrimaryGrade_Enrol) as Total_PrimaryGrade_Enrol,
    sum(es.Upper_PrimaryGrade_Enrol) as Total_Upper_PrimaryGrade_Enrol,
    sum(es.Govt_Enrol_all) as Total_Govt_Enrol_all,
    sum(es.Pvt_Enrol_all) as Total_Pvt_Enrol_all,
    sum(es.GovtRural_Enrol_all) as Total_GovtRural_Enrol_all,
    sum(es.PvtRural_Enrol_all) as Total_PvtRural_Enrol_all
from
	enrol_school_type es
		Inner join
	school s on es.School_School_ID=s.School_ID
		Inner join
	districts d on s.Districts_District_ID=d.District_ID
		inner join
	states st on d.States_States_ID=st.States_ID
where
	es.Data_Year='2015' 
group by States_ID
order by States_ID;


## enrolments by states for 2016 ##
select
	st.States_ID,
    es.Data_Year,
    st.States_name,
	sum(es.PrimaryGrade_Enrol) as Total_PrimaryGrade_Enrol,
    sum(es.Upper_PrimaryGrade_Enrol) as Total_Upper_PrimaryGrade_Enrol,
    sum(es.Govt_Enrol_all) as Total_Govt_Enrol_all,
    sum(es.Pvt_Enrol_all) as Total_Pvt_Enrol_all,
    sum(es.GovtRural_Enrol_all) as Total_GovtRural_Enrol_all,
    sum(es.PvtRural_Enrol_all) as Total_PvtRural_Enrol_all
from
	enrol_school_type es
		Inner join
	school s on es.School_School_ID=s.School_ID
		Inner join
	districts d on s.Districts_District_ID=d.District_ID
		inner join
	states st on d.States_States_ID=st.States_ID
where
	es.Data_Year='2016' 
group by States_ID
order by States_ID;

### 1a) Enrolments by social_Group ###
select
	Data_Year,
    sum(SC_Enrol_Prim_Girls) as Total_Sc_Enrol_Primary_Girls,
    sum(SC_Enrol_UP_Girls) as Total_SC_Enrol_Upper_Primary_Girls,
    sum(ST_Enrol_Prim_Girls) as Total_ST_Enrol_Primary_Girls,
    sum(ST_Enrol_UP_Girls) as Total_ST_Enrol_UpperPrimary_Girls,
    sum(OBC_Enrol_Prim_Girls) as Total_OBC_Enrol_Primary_Girls,
    sum(OBC_Enrol_UP_Girls) as Total_OBC_Enrol_UpperPrimary_Girls,
    sum(Muslim_Enrol_Prim_Girls) as Total_Muslim_Enrol_Primary_Girls,
    sum(Muslim_Enrol_UP_Girls) as Total_Muslim_Enrol_UpperPrimary_Girls
from
	enrol_social_grp
group by Data_Year;

  ########################### Teacher's Qualification  ###########################
 
 
##Seeing States with most and least number of teacher who have below secondary qualification (exclusing Union Territories to remove size effect)
SELECT DISTINCT c.* 
FROM (
	SELECT a.*
    FROM (
		SELECT 
			states.States_name as State, sum(teacher_qual.QUAL_Below_Secondary) as TeachersQual_BelowSecondary_WORST_BEST
		FROM 
			states, teacher_qual
		WHERE  states.States_ID = teacher_qual.States_States_ID 
        AND states.States_name NOT in ('DELHI', 'DAMAN & DIU', 'DADRA & NAGAR HAVELI', 'LAKSHADWEEP', 'PUDUCHERRY', 'A & N ISLANDS') 
		GROUP BY states.States_name
		ORDER BY TeachersQual_BelowSecondary_WORST_BEST DESC
		LIMIT 5) a
	UNION
	SELECT b.*
    FROM(
		SELECT 
			states.States_name as State, sum(QUAL_Below_Secondary) as TeachersQual_BelowSecondary_WORST_BEST
		FROM 
			states, teacher_qual
		WHERE states.States_ID = teacher_qual.States_States_ID
		AND states.States_name NOT in ('DELHI', 'DAMAN & DIU', 'DADRA & NAGAR HAVELI', 'LAKSHADWEEP', 'PUDUCHERRY', 'A & N ISLANDS')
        GROUP BY states.States_name
		ORDER BY TeachersQual_BelowSecondary_WORST_BEST 
		LIMIT 5) b
    )c;

## Comparing states to understand relation between lowest level of teacher's qualification and lowest learning outcomes##

SELECT DISTINCT c.* 
FROM (
	SELECT a.*
    FROM (
		SELECT 
			states.States_name as State, sum(teacher_qual.QUAL_Below_Secondary) as TeachersQual_BelowSecondary, ROUND(avg(Reading_Nothing),2) as Inability_Reading,  ROUND(avg(Arithematic_Nothing),2) as Inability_Maths
		FROM 	
			states, teacher_qual, learning_outcomes
		WHERE  states.States_ID = teacher_qual.States_States_ID AND states.States_ID = learning_outcomes.States_States_ID
        AND states.States_name NOT in ('DELHI', 'DAMAN & DIU', 'DADRA & NAGAR HAVELI', 'LAKSHADWEEP', 'PUDUCHERRY', 'A & N ISLANDS', 'CHANDIGARH') 
		GROUP BY states.States_name
		ORDER BY TeachersQual_BelowSecondary DESC
		LIMIT 5) a
	UNION
	SELECT b.*
    FROM(
		SELECT 
			states.States_name as State, sum(teacher_qual.QUAL_Below_Secondary) as TeachersQual_BelowSecondary, ROUND(avg(Reading_Nothing),2) as Inability_Reading, ROUND(avg(Arithematic_Nothing),2) as Inability_Maths
		FROM 	
			states, teacher_qual, learning_outcomes
		WHERE states.States_ID = teacher_qual.States_States_ID AND states.States_ID = learning_outcomes.States_States_ID
		AND states.States_name NOT in ('DELHI', 'DAMAN & DIU', 'DADRA & NAGAR HAVELI', 'LAKSHADWEEP', 'PUDUCHERRY', 'A & N ISLANDS', 'CHANDIGARH')
        GROUP BY states.States_name
		ORDER BY TeachersQual_BelowSecondary
		LIMIT 5) b
    )c;

 ########################### Understanding Learning Outcomes ###########################

##Studying Effect of expense of textbooks for children on their basic learning outcomes, by state##
SELECT DISTINCT c.* 
FROM (
	SELECT a.*
    FROM (
		SELECT 
			states.States_name as State, sum(incentives.TxtBook_all) as Expense_TxtBook, ROUND(avg(Reading_Nothing),2) as Inability_Reading, ROUND(avg(Arithematic_Nothing),2) as Inability_Maths
		FROM 
			states, incentives, learning_outcomes
		WHERE  states.States_ID = incentives.States_States_ID AND states.States_ID = learning_outcomes.States_States_ID
        AND states.States_name NOT in ('DELHI', 'DAMAN & DIU', 'DADRA & NAGAR HAVELI', 'LAKSHADWEEP', 'PUDUCHERRY', 'A & N ISLANDS', 'CHANDIGARH') 
		GROUP BY states.States_name
		ORDER BY Expense_TxtBook DESC
		LIMIT 5) a
	UNION
	SELECT b.*
    FROM(
		SELECT states.States_name as State, sum(incentives.TxtBook_all) as Expense_TxtBook, ROUND(avg(Reading_Nothing),2) as Inability_Reading, ROUND(avg(Arithematic_Nothing),2) as Inability_Maths
		FROM states, incentives, learning_outcomes
		WHERE  states.States_ID = incentives.States_States_ID AND states.States_ID = learning_outcomes.States_States_ID
		AND states.States_name NOT in ('DELHI', 'DAMAN & DIU', 'DADRA & NAGAR HAVELI', 'LAKSHADWEEP', 'PUDUCHERRY', 'A & N ISLANDS', 'CHANDIGARH')
        GROUP BY states.States_name
		ORDER BY Expense_TxtBook 
		LIMIT 5) b
    )c;
    
  ##Studying Effect of expense of textbooks (states with most and least expenses) for children on their basic learning outcomes##
  
SELECT DISTINCT c.* 
FROM (
	SELECT a.*
    FROM (
		SELECT 
			states.States_name as State, sum(incentives.TxtBook_all) as Expense_TxtBook, ROUND(avg(Std1_Para),2) as Ability_ReadBasic, ROUND(avg(Arithematic_Subtraction),2) as Ability_BasicMaths
		FROM 
			states, incentives, learning_outcomes
		WHERE  states.States_ID = incentives.States_States_ID AND states.States_ID = learning_outcomes.States_States_ID
        AND states.States_name NOT in ('DELHI', 'DAMAN & DIU', 'DADRA & NAGAR HAVELI', 'LAKSHADWEEP', 'PUDUCHERRY', 'A & N ISLANDS', 'CHANDIGARH') 
		GROUP BY states.States_name
		ORDER BY Expense_TxtBook DESC
		LIMIT 5) a
	UNION
	SELECT b.*
    FROM(
		SELECT 
			states.States_name as State, sum(incentives.TxtBook_all) as Expense_TxtBook, ROUND(avg(Std1_Para),2) as Ability_ReadBasic, ROUND(avg(Arithematic_Subtraction),2) as Ability_BasicMaths
		FROM 
			states, incentives, learning_outcomes
		WHERE  states.States_ID = incentives.States_States_ID AND states.States_ID = learning_outcomes.States_States_ID
		AND states.States_name NOT in ('DELHI', 'DAMAN & DIU', 'DADRA & NAGAR HAVELI', 'LAKSHADWEEP', 'PUDUCHERRY', 'A & N ISLANDS', 'CHANDIGARH')
        GROUP BY states.States_name
		ORDER BY Expense_TxtBook 
		LIMIT 5) b
    )c;
    
    ##### Inference #####
    ##Surprisingly Textbooks as incentives do not seem to have any particular role in improving learning outcom##
    
## comparing learning outomes for states which spent the most and least on TLM grants
## Union Territories have been excluded to eleminate size effects
 
SELECT DISTINCT c.* 
FROM (
	SELECT a.*
    FROM (
		SELECT 
			states.States_name as State, sum(grants.TLM_expended) as TLM_Utilization, ROUND(avg(Std1_Para),2) as Ability_ReadBasic, ROUND(avg(Arithematic_Subtraction),2) as Ability_BasicMaths
		FROM 
			states, grants, learning_outcomes
		WHERE  states.States_ID = grants.States_States_ID AND states.States_ID = learning_outcomes.States_States_ID
        AND states.States_name NOT in ('DELHI', 'DAMAN & DIU', 'DADRA & NAGAR HAVELI', 'LAKSHADWEEP', 'PUDUCHERRY', 'A & N ISLANDS', 'CHANDIGARH') 
		GROUP BY states.States_name
		ORDER BY TLM_Utilization DESC
		LIMIT 5) a
	UNION
	SELECT b.*
    FROM(
		SELECT states.States_name as State, sum(grants.TLM_expended) as TLM_Utilization, ROUND(avg(Std1_Para),2) as Ability_ReadBasic, ROUND(avg(Arithematic_Subtraction),2) as Ability_BasicMaths
		FROM states, grants, learning_outcomes
		WHERE  states.States_ID = grants.States_States_ID AND states.States_ID = learning_outcomes.States_States_ID
		AND states.States_name NOT in ('DELHI', 'DAMAN & DIU', 'DADRA & NAGAR HAVELI', 'LAKSHADWEEP', 'PUDUCHERRY', 'A & N ISLANDS', 'CHANDIGARH')
        GROUP BY states.States_name
		ORDER BY TLM_Utilization
		LIMIT 5) b
    )c;

SELECT DISTINCT c.* 
FROM (
	SELECT a.*
    FROM (
		SELECT 
			states.States_name as State, sum(teacher_qual.Male_InService_Training + teacher_qual.Female_InService_Training) as InServiceTraining, ROUND(avg(Std1_Para),2) as Ability_ReadBasic, ROUND(avg(Arithematic_Subtraction),2) as Ability_BasicMaths
		FROM 
			states, teacher_qual, learning_outcomes
		WHERE  states.States_ID = teacher_qual.States_States_ID AND states.States_ID = learning_outcomes.States_States_ID
        AND states.States_name NOT in ('DELHI', 'DAMAN & DIU', 'DADRA & NAGAR HAVELI', 'LAKSHADWEEP', 'PUDUCHERRY', 'A & N ISLANDS', 'CHANDIGARH') 
		GROUP BY states.States_name
		ORDER BY InServiceTraining DESC
		LIMIT 5) a
	UNION
	SELECT b.*
    FROM(
		SELECT 
			states.States_name as State, sum(teacher_qual.Male_InService_Training + teacher_qual.Female_InService_Training) as InServiceTraining, ROUND(avg(Std1_Para),2) as Ability_ReadBasic, ROUND(avg(Arithematic_Subtraction),2) as Ability_BasicMaths
		FROM 
			states, teacher_qual, learning_outcomes
		WHERE  states.States_ID = teacher_qual.States_States_ID AND states.States_ID = learning_outcomes.States_States_ID
		AND states.States_name NOT in ('DELHI', 'DAMAN & DIU', 'DADRA & NAGAR HAVELI', 'LAKSHADWEEP', 'PUDUCHERRY', 'A & N ISLANDS', 'CHANDIGARH')
        GROUP BY states.States_name
		ORDER BY InServiceTraining
		LIMIT 5) b
    )c;

## Studying Basic Reading and Maths learning outcomes for schools were teachers recieve inservice Training
## Aggregated over States (Top Ten Schools by number of schools where inservice training is supported)
## Union Territories have been excluded to eleminate size effects

SELECT DISTINCT a.*
    FROM (
		SELECT 
			states.States_name as State, sum(teacher_qual.Male_InService_Training + teacher_qual.Female_InService_Training) as InServiceTraining, ROUND(avg(Std1_Para),2) as Ability_ReadBasic, ROUND(avg(Arithematic_Subtraction),2) as Ability_BasicMaths
		FROM 
			states, teacher_qual, learning_outcomes
		WHERE  states.States_ID = teacher_qual.States_States_ID AND states.States_ID = learning_outcomes.States_States_ID
        AND states.States_name NOT in ('DELHI', 'DAMAN & DIU', 'DADRA & NAGAR HAVELI', 'LAKSHADWEEP', 'PUDUCHERRY', 'A & N ISLANDS', 'CHANDIGARH') 
		GROUP BY states.States_name
		ORDER BY InServiceTraining DESC
		LIMIT 10) a;

## Studying Pupil Teacher Ratios (PTR) in Primary and Upper Primary Classes in Schools, against basic Learning Outcomes
## Aggregated for states. PTR ratios values correspond to number of schools per district
## Union Territories have been excluded to eleminate size effects

SELECT DISTINCT c.* 
FROM (
	SELECT a.*
    FROM (
		SELECT 
			states.States_name as State, sum(key_ratios.Primary_PTR_30) as Primary_PTR_morethan30, sum(key_ratios.UpperPrim_PTR_35) as UPrimaryPTR_morethan35,ROUND(avg(Std1_Para),2) as Ability_ReadBasic, ROUND(avg(Arithematic_Subtraction),2) as Ability_BasicMaths
		FROM 
			states, key_ratios, learning_outcomes
		WHERE  states.States_ID = key_ratios.States_States_ID AND states.States_ID = learning_outcomes.States_States_ID
        AND key_ratios.Data_Year = 2016 AND learning_outcomes.Data_Year = 2016
        AND states.States_name NOT in ('DELHI', 'DAMAN & DIU', 'DADRA & NAGAR HAVELI', 'LAKSHADWEEP', 'PUDUCHERRY', 'A & N ISLANDS', 'CHANDIGARH') 
		GROUP BY states.States_name
		ORDER BY Primary_PTR_morethan30 DESC
		LIMIT 5) a
	UNION
	SELECT b.*
    FROM (
		SELECT 
			states.States_name as State, sum(key_ratios.Primary_PTR_30) as Primary_PTR_morethan30, sum(key_ratios.UpperPrim_PTR_35) as UPrimaryPTR_morethan35,ROUND(avg(Std1_Para),2) as Ability_ReadBasic, ROUND(avg(Arithematic_Subtraction),2) as Ability_BasicMaths
		FROM 
			states, key_ratios, learning_outcomes
		WHERE  states.States_ID = key_ratios.States_States_ID AND states.States_ID = learning_outcomes.States_States_ID
		AND key_ratios.Data_Year = 2016 AND learning_outcomes.Data_Year = 2016
        AND states.States_name NOT in ('DELHI', 'DAMAN & DIU', 'DADRA & NAGAR HAVELI', 'LAKSHADWEEP', 'PUDUCHERRY', 'A & N ISLANDS', 'CHANDIGARH') 
		GROUP BY states.States_name
		ORDER BY Primary_PTR_morethan30
		LIMIT 5) b
    )c;

SELECT DISTINCT d.* 
FROM (
	SELECT a.*
    FROM (
		SELECT 
			key_ratios.Data_Year, states.States_name as State, sum(key_ratios.Primary_PTR_30) as Primary_PTR_morethan30, sum(key_ratios.UpperPrim_PTR_35) as UPrimaryPTR_morethan35,ROUND(avg(Std1_Para),2) as Ability_ReadBasic, ROUND(avg(Arithematic_Subtraction),2) as Ability_BasicMaths
		FROM 
			states, key_ratios, learning_outcomes
		WHERE  states.States_ID = key_ratios.States_States_ID AND states.States_ID = learning_outcomes.States_States_ID
        AND key_ratios.Data_Year = 2016
        AND states.States_name NOT in ('DELHI', 'DAMAN & DIU', 'DADRA & NAGAR HAVELI', 'LAKSHADWEEP', 'PUDUCHERRY', 'A & N ISLANDS', 'CHANDIGARH') 
		GROUP BY states.States_name
		ORDER BY Primary_PTR_morethan30 DESC
		LIMIT 5) a
	UNION
	SELECT DISTINCT b1.*
    FROM (
    SELECT b.*
    FROM (
		SELECT 
			key_ratios.Data_Year, states.States_name as State, sum(key_ratios.Primary_PTR_30) as Primary_PTR_morethan30, sum(key_ratios.UpperPrim_PTR_35) as UPrimaryPTR_morethan35,ROUND(avg(Std1_Para),2) as Ability_ReadBasic, ROUND(avg(Arithematic_Subtraction),2) as Ability_BasicMaths
		FROM 
			states, key_ratios, learning_outcomes
		WHERE states.States_ID = key_ratios.States_States_ID AND states.States_ID = learning_outcomes.States_States_ID
        AND key_ratios.Data_Year = 2015
	    AND states.States_name NOT in ('DELHI', 'DAMAN & DIU', 'DADRA & NAGAR HAVELI', 'LAKSHADWEEP', 'PUDUCHERRY', 'A & N ISLANDS', 'CHANDIGARH') 
		GROUP BY states.States_name 
		ORDER BY Primary_PTR_morethan30 DESC
		LIMIT 5) b
	UNION
	SELECT c.*
    FROM (
		SELECT 
			key_ratios.Data_Year, states.States_name as State, sum(key_ratios.Primary_PTR_30) as Primary_PTR_morethan30, sum(key_ratios.UpperPrim_PTR_35) as UPrimaryPTR_morethan35,ROUND(avg(Std1_Para),2) as Ability_ReadBasic, ROUND(avg(Arithematic_Subtraction),2) as Ability_BasicMaths
		FROM 
			states, key_ratios, learning_outcomes
		WHERE states.States_ID = key_ratios.States_States_ID AND states.States_ID = learning_outcomes.States_States_ID
        AND key_ratios.Data_Year = 2014
	    AND states.States_name NOT in ('DELHI', 'DAMAN & DIU', 'DADRA & NAGAR HAVELI', 'LAKSHADWEEP', 'PUDUCHERRY', 'A & N ISLANDS', 'CHANDIGARH') 
		GROUP BY states.States_name
		ORDER BY Primary_PTR_morethan30 DESC
		LIMIT 5) c
        ) b1
    ) d;
    
##ALTER TABLE `districtschoolreport`.`facilities_infra` 
##CHANGE COLUMN `MiddayMeal_Govt&Aided` `MiddayMeal_GovtandAided` INT(11) NULL DEFAULT NULL ;

 SELECT d.Data_Year, d.District_name, d.MiddayMeal_GovtandAided as MidDayMeal_Facility, 
 enrol_school_type.PrimaryGrade_Enrol+ enrol_school_type.Upper_PrimaryGrade_Enrol as Total_Enrollment
 FROM enrol_school_type, 
 (SELECT d.*
 FROM (
 SELECT *
 FROM districts INNER JOIN facilities_infra 
 ON districts.States_States_ID = facilities_infra.States_States_ID)) as d
 WHERE enrol_school_type.School_School_ID = d.School_School_ID
 ORDER BY d.Data_Year DESC;
    