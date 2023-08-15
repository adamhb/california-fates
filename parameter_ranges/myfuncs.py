m2_per_cm2 = 1e-4
g_biomass_per_g_C = 2
m2_per_mm2 = 1e-6
mg_per_g = 1e3
g_per_kg = 1000
mm2_per_cm2 = 100
g_per_mg = 1e-3

def convert_to_fates_units(trait_name,input_units,input_value):
    
    if "SLA" in trait_name and input_units == "mm2 mg-1":
        output_value = input_value * m2_per_mm2 * mg_per_g * g_biomass_per_g_C
        return output_value
    
    elif "Leaf nitrogen" in trait_name and input_units == "mg/g":
        output_value = input_value * g_per_mg * g_biomass_per_g_C
        return output_value
    
    elif "Stem specific density" in trait_name and input_units == "g/cm3":
        output_value = input_value
        return output_value
    
    else:
        print("No unit conversion known for:", trait_name)
        return None
    
#def convert_to_fates_variable_name (pick up here)
