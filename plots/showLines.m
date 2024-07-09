function showLines(handle, on_off)

try
    temp = handle.Visible; % Just to see if it has a visibility field.
    handle.Visible = on_off;
catch
    % Doesn't have visibility. 
    names = fields(handle);

    for i=1:length(names)
        showLines(handle.(names{i}), on_off);
    end

end
end