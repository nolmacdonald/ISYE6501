import pandas as pd
from pulp import *

# Load the diet data into a DataFrame
path_data = "~/projects/ISYE6501/HW11/data/diet.xls"
diet_data = pd.read_excel(path_data)
diet_data.head(5)

# Check for nan values in the diet data
nan_vals = diet_data.isna().sum()
print(f"Number of Missing Values by Column:\n{len(diet_data)}")
print(f"Number of rows in the diet data: {len(diet_data)}")

# Keep only the 64 data points with no missing values
diet_data_clean = diet_data[0:64]
print(f"Number of rows in the diet data: {len(diet_data_clean)}")
diet_data_clean.head(5)

# Check for nan values in the diet data
nan_vals_clean = diet_data_clean.isna().sum()
print(nan_vals_clean)

# Model --------------------------------------------------------------------------------
# Initialize by creating an LP problem
diet_prob = LpProblem("cheapest_diet", LpMinimize)

# Unique list of foods
foods = []
for each in diet_data_clean["Foods"]:
    foods.append(each)
print(foods)

# Create a nested list of diet data values
list_data = diet_data_clean.values.tolist()

# Create dictionaries using dictionary comprehensions
# "Price/ Serving"
cost_dict = {each[0]: each[1] for each in list_data}
# "Calories"
cals_dict = {each[0]: each[3] for each in list_data}
# "Cholesterol mg"
choles_dict = {each[0]: each[4] for each in list_data}
# "Total_Fat g"
fat_dict = {each[0]: each[5] for each in list_data}
# "Sodium mg"
sod_dict = {each[0]: each[6] for each in list_data}
# "Carbohydrates g"
carb_dict = {each[0]: each[7] for each in list_data}
# "Dietary_Fiber g"
fiber_dict = {each[0]: each[8] for each in list_data}
# "Protein g"
pro_dict = {each[0]: each[9] for each in list_data}
# "Vit_A IU"
VA_dict = {each[0]: each[10] for each in list_data}
# "Vit_C IU"
VC_dict = {each[0]: each[11] for each in list_data}
# "Calcium mg"
calc_dict = {each[0]: each[12] for each in list_data}
# "Iron mg"
iron_dict = {each[0]: each[13] for each in list_data}

# dictionary called ‘food_vars’ is created to contain the referenced Variables
food_vars = LpVariable.dicts("Foods",foods,0)

# objective function is added to ‘basic_prob’ first
diet_prob += lpSum([cost_dict[i]*food_vars[i] for i in foods]), "Total Food Cost"

# Diet constraints
diet_prob += lpSum([cals_dict[i] * food_vars[i] for i in foods]) >= 1500, "Min_Calorie_Requirement"
diet_prob += lpSum([cals_dict[i] * food_vars[i] for i in foods]) <= 2500, "Max_Calorie_Requirement"
diet_prob += lpSum([choles_dict[i] * food_vars[i] for i in foods]) >= 30, "Min_Cholesterol_Requirement"
diet_prob += lpSum([choles_dict[i] * food_vars[i] for i in foods]) <= 240, "Max_Cholesterol_Requirement"
diet_prob += lpSum([fat_dict[i] * food_vars[i] for i in foods]) >= 20, "Min_Fat_Requirement"
diet_prob += lpSum([fat_dict[i] * food_vars[i] for i in foods]) <= 70, "Max_Fat_Requirement"
diet_prob += lpSum([sod_dict[i] * food_vars[i] for i in foods]) >= 800, "Min_Sodium_Requirement"
diet_prob += lpSum([sod_dict[i] * food_vars[i] for i in foods]) <= 2000, "Max_Sodium_Requirement"
diet_prob += lpSum([carb_dict[i] * food_vars[i] for i in foods]) >= 130, "Min_Carb_Requirement"
diet_prob += lpSum([carb_dict[i] * food_vars[i] for i in foods]) <= 450, "Max_Carb_Requirement"
diet_prob += lpSum([fiber_dict[i] * food_vars[i] for i in foods]) >= 125, "Min_Fiber_Requirement"
diet_prob += lpSum([fiber_dict[i] * food_vars[i] for i in foods]) <= 250, "Max_Fiber_Requirement"
diet_prob += lpSum([pro_dict[i] * food_vars[i] for i in foods]) >= 60, "Min_Protein_Requirement"
diet_prob += lpSum([pro_dict[i] * food_vars[i] for i in foods]) <= 100, "Max_Protein_Requirement"
diet_prob += lpSum([VA_dict[i] * food_vars[i] for i in foods]) >= 1000, "Min_VA_Requirement"
diet_prob += lpSum([VA_dict[i] * food_vars[i] for i in foods]) <= 10000, "Max_VA_Requirement"
diet_prob += lpSum([VC_dict[i] * food_vars[i] for i in foods]) >= 400, "Min_VC_Requirement"
diet_prob += lpSum([VC_dict[i] * food_vars[i] for i in foods]) <= 5000, "Max_VC_Requirement"
diet_prob += lpSum([calc_dict[i] * food_vars[i] for i in foods]) >= 700, "Min_Calcium_Requirement"
diet_prob += lpSum([calc_dict[i] * food_vars[i] for i in foods]) <= 1500, "Max_Calcium_Requirement"
diet_prob += lpSum([iron_dict[i] * food_vars[i] for i in foods]) >= 10, "Min_Iron_Requirement"
diet_prob += lpSum([iron_dict[i] * food_vars[i] for i in foods]) <= 40, "Max_Iron_Requirement"

# Constraint A
# Add binary variable for the constraint of selecting a food
food_vars_selected = LpVariable.dicts("Selected",foods,0,1,LpBinary)

# If a food is eaten, must eat at least 0.1 serving
for food in foods:
    diet_prob += food_vars[food] >= 0.1 * food_vars_selected[food]
    
# If any of a food is eaten, its binary variable must be 1
for food in foods:
    diet_prob += food_vars_selected[food] >= food_vars[food]*0.0000001 

# Constraint B
# Include at most 1 of celery and frozen broccoli 
diet_prob += food_vars_selected['Frozen Broccoli'] + food_vars_selected['Celery, Raw'] <= 1 

# Constraint C
# At least 3 kinds of meat/poultry/fish/eggs
diet_prob += food_vars_selected['Roasted Chicken'] \
        + food_vars_selected['Poached Eggs'] \
        + food_vars_selected['Scrambled Eggs'] \
        + food_vars_selected['Bologna,Turkey'] \
        + food_vars_selected['Frankfurter, Beef'] \
        + food_vars_selected['Ham,Sliced,Extralean'] \
        + food_vars_selected['Kielbasa,Prk'] \
        + food_vars_selected['Pizza W/Pepperoni'] \
        + food_vars_selected['Hamburger W/Toppings'] \
        + food_vars_selected['Hotdog, Plain'] \
        + food_vars_selected['Pork'] \
        + food_vars_selected['Sardines in Oil'] \
        + food_vars_selected['White Tuna in Water'] \
        + food_vars_selected['Chicknoodl Soup'] \
        + food_vars_selected['Splt Pea&Hamsoup'] \
        + food_vars_selected['Vegetbeef Soup'] \
        + food_vars_selected['Neweng Clamchwd'] \
        + food_vars_selected['New E Clamchwd,W/Mlk'] \
        + food_vars_selected['Beanbacn Soup,W/Watr'] >= 3

# write the problem to an LP file
diet_prob.writeLP("HW11/data/cheapest_diet.lp")

# call the solver and check the status
diet_prob.solve()

print("Status:", LpStatus[diet_prob.status])

print(f"\nTotal Cost of the Cheapest Nutritional Diet: ${value(diet_prob.objective):.2f}")

# Print the main foods of the diet
results = {}
for v in diet_prob.variables():
    if v.varValue > 0:
        print(f"{v.name}: {v.varValue}")
        # Save the results in a dictionary
        results[v.name] = v.varValue

# Create a DataFrame from the dictionary
results_df = pd.DataFrame(list(results.items()), columns=['Food', 'Servings'])

print(results_df)