function cnn_pre(wavein,dim,outputname)
% Function dedicated for converting vector variabe into png files (for use of CNN input)

if min(wavein) < 0 ;
    wavein = wavein + abs(min(wavein));
end

% wave = wavein/max(wavein)*dim; 

fig1 = figure(1); plot(wavein,'k'); 

set(gca,'visible','off');

set(fig1,'PaperUnits','inches','PaperPosition',[0 0 2 2]);

print('-dpng', outputname, '-r100');
% saveas(gcf, outputname, 'png')

end

