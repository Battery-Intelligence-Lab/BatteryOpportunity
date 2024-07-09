function [heavy, moder, light, EOL, opt] = getLines(f)
ax = f.Children;
heavy = struct();
moder = struct();
light = struct();
EOL   = struct();
opt   = struct();

heavy.rev.text   = ax(1).Children(2);
moder.rev.text   = ax(1).Children(1);
light.rev.text   = ax(1).Children(3);
EOL.rev.text     = ax(1).Children(4);

heavy.use.text   = ax(2).Children(4);
moder.use.text   = ax(2).Children(3);
light.use.text   = ax(2).Children(2);
EOL.use.text     = ax(2).Children(1);

light.use.line   = ax(2).Children(5);
moder.use.line   = ax(2).Children(6);
heavy.use.line   = ax(2).Children(7);


opt.rev.star = ax(1).Children(5);
hAnnotAxes = findall(f,'Tag','scribeOverlay');
opt.rev.arrow = hAnnotAxes(1).Children;

EOL.rev.line = ax(1).Children(6);

light.rev.max = ax(1).Children(7);
moder.rev.max = ax(1).Children(9);
heavy.rev.max = ax(1).Children(11);

light.rev.line = ax(1).Children(8);
moder.rev.line = ax(1).Children(10);
heavy.rev.line = ax(1).Children(12);

end