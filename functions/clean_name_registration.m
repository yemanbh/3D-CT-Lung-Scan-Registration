function CleanName = clean_name_registration(Name, Delimeter)
C = strsplit(Name,Delimeter);
CleanName = C{1};
end