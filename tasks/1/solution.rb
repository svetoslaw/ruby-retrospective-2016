MELTING_POINTS = { 
  'water' => 0, 
  'ethanol' => -114, 
  'gold' => 1_064, 
  'silver' => 961.8, 
  'copper' => 1_085, 
}

BOILING_POINTS = { 
  'water' => 100,
  'ethanol' => 78.37,
  'gold' => 2_700,
  'silver' => 2_162,
  'copper' => 2_567, 
}

def convert_to_celsius(degrees, input_unit)
  if input_unit == 'C'
    degrees
  elsif input_unit == 'K'
    degrees - 273.15
  elsif input_unit == 'F'
    (degrees - 32) / 1.8
  end
end

def convert_from_celsius(degrees, output_unit)
  if output_unit == 'C'
    degrees
  elsif output_unit == 'K'
    degrees + 273.15
  elsif output_unit == 'F'
    degrees * 1.8 + 32
  end
end

def convert_between_temperature_units(degrees, input_unit, output_unit)
  if input_unit == output_unit
    degrees
  else
    temp = convert_to_celsius(degrees, input_unit)
    convert_from_celsius(temp, output_unit)
  end
end

def melting_point_of_substance(substance, unit)
  convert_from_celsius(MELTING_POINTS[substance], unit)
end

def boiling_point_of_substance(substance, unit)
  convert_from_celsius(BOILING_POINTS[substance], unit)
end