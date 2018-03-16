figure('Position', [250 150 900 900]);
% set(gcf,'Renderer','OpenGL');

% Short trial setup
% axes('Position', [left bottom width height])
vr.short_plot = axes('Position', [0.07 0.62 0.9 0.35]);

vr.short_plot.XLimMode = 'manual';
vr.short_plot.XLim = [50 350];
% vr.short_plot.YLim = [0 200];
vr.short_plot.XLabel.String = 'Location (cm)';
vr.short_plot.YLabel.String = 'Trial #';
vr.short_plot.Title.String = 'Short trials'; 

% Adds reference lines for landmark
vline([200 240], {'k', 'k'})
annotation('rectangle', [0.52 0.62 0.12 0.35],'FaceColor','black','FaceAlpha',.1)

% Adds reference lines for reward zone
vline([320 340], {'k', 'k'})
annotation('rectangle', [0.88 0.62 0.06 0.35],'FaceColor', 'blue','FaceAlpha',.1)

% Long trial setup
vr.long_plot = axes('Position', [0.07 0.195 0.9 0.35]);

vr.long_plot.XLimMode = 'manual';
vr.long_plot.XLim = [50 410];
% vr.long_plot.YLim = [0 200];
vr.long_plot.XLabel.String = 'Location (cm)';
vr.long_plot.YLabel.String = 'Trial #';
vr.long_plot.Title.String = 'Long trials';

% Adds reference lines for landmark
vline([200 240], {'k', 'k'})
annotation('rectangle',[0.445 0.195 0.1 0.35],'FaceColor','black','FaceAlpha',.1)

% Adds reference lines for reward zone box
vline([380 400], {'k', 'k'})
annotation('rectangle', [0.895 0.195 0.05 0.35],'FaceColor','magenta','FaceAlpha',.1)

stats = annotation('textbox', [0.15 0.1 0.2 0], 'string', ['Trials per minute: ' 12]);
stats.FontSize = 14;
stats.LineStyle = 'none';
