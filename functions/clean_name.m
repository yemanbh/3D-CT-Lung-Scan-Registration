function CleanName = clean_name(Name)
C = strsplit(Name,'.');
CleanName = C{1};
end