function axishandle=nicepie(X,labels)
% Version of pie that makes nice figures for the Placebo
% Mega-Analysis

figure() % New figure
h = pie(X);

    hText = findobj(h,'Type','text'); % text object handles
    set(hText,'FontSize',14); %Set fontsize of text
    percentValues = get(hText,'String'); % percent values

if exist('labels')
    str = labels; % strings
    combinedstrings = strcat(str,percentValues); % strings and percent values
    % Get positions of text labels before assigning new text
    oldExtents_cell = get(hText,'Extent'); % cell array
    oldExtents = cell2mat(oldExtents_cell); % numeric array
    % Assign new text
    hText(1).String = combinedstrings(1);
    hText(2).String = combinedstrings(2);
    % Get new positions
    newExtents_cell = get(hText,'Extent'); % cell array
    newExtents = cell2mat(newExtents_cell); % numeric array
    % Calculate new positions
    width_change = newExtents(:,3)-oldExtents(:,3);
    signValues = sign(oldExtents(:,1));
    offset = signValues.*(width_change/2);
    textPositions_cell = get(hText,{'Position'}); % cell array
    textPositions = cell2mat(textPositions_cell); % numeric array
    textPositions(:,1) = textPositions(:,1) + offset; % add offset
    % Assign new text positions
    hText(1).Position = textPositions(1,:);
    hText(2).Position = textPositions(2,:);
    
end

colormap(jet(hsv))
axishandle=gca

end

