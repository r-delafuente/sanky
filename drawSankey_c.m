function drawSankey_c(inputs, losses, unit, labels, colour, varargin)
 
% drawSankey_c(inputs, losses, unit, labels, colour, sep)
%
% drawSankey is a matlab function that draws single-direction Sankey
% diagrams (i.e no feedback loops), however, multiple inputs can be
% specified.
%
% inputs: a vector containing the  flow inputs, the first of which will be
%         considered the main input and drawn centrally, other inputs will
%         be shown below this.
%
% losses: a vector containing all of the losses from the system, which will 
%         be displayed along the top of the Sankey diagram
%
% unit:   a string indicating the unit in which the flows are expressed
%
% labels: a cell list of the labels for the different flows, starting with 
%         the labels for the inputs, then the losses and finally the output
% colour: An RGB triplet is a three-element row vector whose elements 
%         specify the intensities of the red, green, and blue components of
%         the colour. The intensities must be in the range [0,1]
%         Give a triplet RGB for each losses and the output
%
% sep:    an (optional) list of position for separating lines, placed after
%         the loss corresponding to the indexes provided
%
%        
%        
%
% For an example, copy and paste the lines below to the command line:
%
%   inputs = [75 32]; losses = [10 5 2.8]; unit = 'MW'; sep = [1,3];
%   labels = {'Main Input','Aux Input','Losses I','Losses II','Losses III','Output'};
%   colour=[[0 0.4 0.74];[0.30 0.74 0.93];[0.92 0.69 0.125];...
%   [0.63 0.078 0.18];[0.85 0.32 0.09]];
%
%   drawSankey_c(inputs, losses, unit, labels, colour, sep);
%
% Current Version:  02.11.2009
% Developped by:    James SPELLING, KTH-EGI-EKV
%                   spelling@kth.se
% modified on:      02.11.2021
% modified by:      Raul De La Fuente Pinto
%
% Distributed under Creative Commons Attribution + NonCommerical (by-nc)
% Licensees may copy, distribute, display, and perform the work and make
% derivative works based on it only for noncommercial purposes
 
%check parameter values%
if sum(losses) >= sum(inputs)
    
    %report unbalanced inputs and losses%
    error('drawSankey: losses exceed inputs, unable to draw diagram');
    
elseif any(losses < 0) || any(inputs < 0)
    
    %report negative inputs and/or losses%
    error('drawSankey: negative inputs or losses encountered');
    
elseif (size(colour,1)< length(losses)+1)
    %report no suficient colours%
    error('drawSankey: colour inputs wrong size, it has to be losses + output size');
else
    
    %check for the existance of separating lines%
    if nargin > 4; sep = varargin{1}; end
    
    %create plotting window%
    figure('color','white','tag','sankeyDiagram');
    
    %if possible, maximise figure%
    if exist('maximize','file')
        maximize(gcf);
    end
    
    %create plotting axis then hide it%
    axes('position',[0.1 0 0.75 0.75]);
    axis off;
    
    %calculate fractional losses and inputs%
    frLosses = losses/sum(inputs);
    frInputs = inputs/sum(inputs);
    
    if length(inputs(inputs > eps)) == 1
        
        %assemble first input label if only one input%
        inputLabel = sprintf('%s\n%.1f [%s]', labels{1}, inputs(1), unit);
    
    else
        
        %assemble first input label if only several inputs%
        inputLabel = sprintf('%s\n%.1f [%s] %.1f [%%]', labels{1}, inputs(1), unit, 100*frInputs(1));
    
    end
    
    %determine first input label font size%
    fontsize = min(12, 10 + ceil((frInputs(1)-0.05)/0.025));
    
    %draw first input label to plotting window%
    text(0, frInputs(1)/2, inputLabel, 'FontSize', fontsize,'HorizontalAlignment','right','Rotation',0);
    
    %draw back edge of first input arrow%
    line([0.1 0 0.05 0 0.4], [0 0 frInputs(1)/2 frInputs(1) frInputs(1)], 'Color', 'black', 'LineWidth', 2.5);
    
    %set inital position for the top of the arrows%
    limTop = frInputs(1); posTop = 0.4;
    
    %set inital position for the bottom of the arrows%
    limBot(1) = 0; posBot = 0.1;
    
    %draw arrows for additional inputs%
    
    for j = 2 : length(inputs)
        
        %don't draw negligable inputs%
        if frInputs(j) > eps
            
            %determine inner and outer arrow radii%
            rI = max(0.07, abs(frInputs(j)/2));
            rE = rI + abs(frInputs(j));
            
            %push separation point forwards%
            newPosB = posBot + rE*sin(pi/4) + 0.01;
            line([posBot newPosB], [limBot(j-1) limBot(j-1)], 'Color', 'black', 'LineWidth', 2.5);
            posBot = newPosB;
            
            %determine points on the external arc%
            arcEx = posBot - rE*sin(linspace(0,pi/4));
            arcEy = limBot(j-1) - rE*(1 - cos(linspace(0,pi/4)));
            
            %determine points on the internal arc%
            arcIx = posBot - rI*sin(linspace(0,pi/4));
            arcIy = limBot(j-1) - rE + rI*cos(linspace(0,pi/4));
            
            %draw internal and external arcs%
            %line(arcIx, arcIy, 'Color', 'green', 'LineWidth', 2.5);
            %line(arcEx, arcEy, 'Color', 'yellow', 'LineWidth', 2.5);
            
            %determine arrow point tip%
            phiTip = pi/4 - 2*min(0.05, 0.8*abs(frInputs(j)))/(rI + rE);
            xTip = posBot - (rE+rI)*sin(phiTip)/2;
            yTip = limBot(j-1) - rE + (rE+rI)*cos(phiTip)/2;
            
            %draw back edge of additional input arrows%
            %line([min(arcEx) xTip min(arcIx)], [min(arcEy) yTip min(arcIy)], 'Color', 'black', 'LineWidth', 2.5);
            line([0 0.05 0 posBot], [limBot(j-1) limBot(j-1)-frInputs(j)/2 limBot(j-1)-frInputs(j) limBot(j-1)-frInputs(j)], 'Color', 'black', 'LineWidth', 2.5);
          
            %determine text edge location%
            phiText = pi/2 - 2*min(0.05, 0.8*abs(frInputs(j)))/(rI + rE);
            xText = posBot - (rE+rI)*sin(phiText)/2;
            yText = limBot(j-1) - rE + (rE+rI)*cos(phiText)/2;
            
            %determine label size based on importance%
            if frInputs(j) > 0.1
                
                %large inputs text size scales slower%
                fullLabel = sprintf('%s\n%.1f [%s] %.1f [%%]', labels{j}, inputs(j), unit, 100*frInputs(j));
                fontsize = 10 + round((frInputs(j)-0.01)/0.05);
            
            elseif frInputs(j) > 0.05
            
                %smaller but more rapidly scaling losses%
                fullLabel = sprintf('%s: %.1f [%s] %.1f [%%]', labels{j}, inputs(j), unit, 100*frInputs(j));
                fontsize = 10 + ceil((frInputs(j)-0.05)/0.025);
            
            else
            
                %minimum text size for input label%
                fullLabel = sprintf('%s: %.1f [%s] %.1f [%%]',labels{j}, inputs(j), unit, 100*frInputs(j));
                fontsize = 10;
            
            end
            
            %draw input label%
            text(0, limBot(j-1)-frInputs(j)/2, fullLabel, 'FontSize', min(12, fontsize),'HorizontalAlignment','right');
            
            %save new bottom end of arrow%
            limBot(j) = limBot(j-1) - frInputs(j);
            
        end
     
    end
    
    %draw arrows of losses%
 
    for i = 1 : length(losses)
        
        %don't draw negligable losses%
        if frLosses(i) > eps
            
            %determine inner and outer arrow radii%
            rI = max(0.07, abs(frLosses(i)/2));
            rE = rI + abs(frLosses(i));
            
            %determine points on the internal arc%
            arcIx = posTop + rI*sin(linspace(0,pi/2));
            arcIy = limTop + rI*(1 - cos(linspace(0,pi/2)));
            
            %determine points on the external arc%
            arcEx = posTop + rE*sin(linspace(0,pi/2));
            arcEy = (limTop + rI) - rE*cos(linspace(0,pi/2));
            
            %draw internal and external arcs%
            line(arcIx, arcIy, 'Color', 'black', 'LineWidth', 2.5);
            line(arcEx, arcEy, 'Color', 'black', 'LineWidth', 2.5);
            
            %determine arrow tip dimensions%
            arEdge = max(0.015, rI/3);
            arTop  = max(0.04, 0.8*frLosses(i));
            
            %determine points on arrow tip%
            arX = posTop + rI + [0 -arEdge frLosses(i)/2 frLosses(i)+ arEdge frLosses(i)];
            arY = limTop + rI + [0 0 arTop 0 0];
            
            %draw tip of losses arrow%
            line(arX, arY, 'Color', 'black', 'LineWidth', 2.5);
            
            %determine text edge location%
            txtX = posTop + rI + frLosses(i)/2;
            txtY = limTop + rI + arTop + 0.05;
            
            %determine label size based on importance%
            if frLosses(i) > 0.1
                
                %large losses have the space for a two line label%
                fullLabel = sprintf('%s\n%.1f [%%]',labels{i+length(inputs)}, 100*frLosses(i));
                fontsize = 12 + round((frLosses(i)-0.01)/0.05);
                
            elseif frLosses(i) > 0.05
            
                %single line, but still scaling label%
                fullLabel = sprintf('%s: %.1f [%%]',labels{i+length(inputs)}, 100*frLosses(i));
                fontsize = 10 + ceil((frLosses(i)-0.05)/0.025);
            
            else
            
                %minimum siye single line label%
                fullLabel = sprintf('%s: %.1f [%%]',labels{i+length(inputs)}, 100*frLosses(i));
                fontsize = 10;
            
            end
            
            %draw losses label%
            text(txtX, txtY, fullLabel, 'Rotation', 90, 'FontSize', fontsize);
            
            %save new position of arrow top%
            limTop = limTop - frLosses(i);
            
            %advance to new separation point%
            newPos = posTop + rE + 0.01;
            
            %draw top line to new separation point%
            line([posTop newPos], [limTop limTop], 'Color', 'black', 'LineWidth', 2.5);
            
            %save new advancement point%
            posTop = newPos;
            
            %fill colour arrow and arc
            x_arc=[arcEx flip(arcIx)];
            y_arc=[arcEy flip(arcIy)];
            patch(x_arc, y_arc,colour(i,:),'EdgeColor','none');
            patch(arX, arY,colour(i,:),'EdgeColor','none');
            
            %fill colour
            k=1;
            flag=1;
            x(1)=0;
            while ( k<=length(inputs)&&(flag))
                if k>1
                    comp=(limBot(k)+limBot(k-1))/2;
                else
                    comp=frInputs(k)/2;
                end
                if arcEy(1)>=limBot(k)
                    if arcEy(1) >= comp
                        if k>1
                            m=(comp-limBot(k-1))/0.05;
                            x(i+1)=((arcEy(1)-limBot(k-1))/m);
                        else
                            m=(comp-comp*2)/0.05;
                            x(i+1)=((arcEy(1)-(comp*2))/m);
                        end
                        patch([x(i+1) x(i) arcIx(1) arcEx(1)],[arcEy(1) arcIy(1) arcIy(1) arcEy(1)], colour(i,:),'EdgeColor','none');
                        flag=0;
                    elseif arcIy(1)> comp
                        patch([0.05 x(i) arcIx(1) arcEx(1)],[comp arcIy(1) arcIy(1) comp], colour(i,:),'EdgeColor','none');
                        m=(comp-limBot(k))/0.05;
                        x(i+1)=(arcEy(1)-limBot(k))/m;
                        patch([x(i+1) 0.05 arcIx(1) arcEx(1)],[arcEy(1) comp comp arcEy(1)], colour(i,:),'EdgeColor','none');
                        flag=0;
                    else
                        m=(comp-limBot(k))/0.05;
                        x(i+1)=(arcEy(1)-limBot(k))/m;
                        patch([x(i+1) x(i) arcIx(1) arcEx(1)],[arcEy(1) arcIy(1) arcIy(1) arcEy(1)], colour(i,:),'EdgeColor','none');
                        flag=0;
                    end
                elseif arcIy(1)>limBot(k)
                    %is the first input complete
                    patch([0 x(i) arcIx(1) arcEx(1)],[limBot(k) arcIy(1) arcIy(1) limBot(k)], colour(i,:),'EdgeColor','none');
                    arcIy(1)=limBot(k);
                    x(i)=0;
                    k=k+1;
               else
                    k=k+1;
                end
            end
    end
        
        %separation lines%
        
        if any(i == sep)
            
            if length(inputs) > 1 && any(inputs(2 : length(inputs)) > eps)
                
                %if there are additional inputs, determine approx. sep. line%
                xLeft = 0.1*posTop;
            
            else
            
                %otherwise determine exact sep. line%
                xLeft = 0.05 * (1 - 2*abs(limTop - 0.5));
            
            end
 
            %draw the line%
            line([xLeft posTop], [limTop limTop], 'Color', 'black', 'LineWidth', 2, 'LineStyle','--');
            %line([0.05 posTop], [limTop limTop], 'Color', 'black', 'LineWidth', 2, 'LineStyle','--');
        end
    end
    
    %push the arrow forwards a little after all side-arrows drawn%
    newPos = max(posTop, posBot) + max(0.05*limTop, 0.05);
    
    %draw lines to this new position%
    line([posTop, newPos],[limTop limTop], 'Color', 'black', 'LineWidth', 2.5);
    line([posBot, newPos],[limBot(end) limBot(end)], 'Color', 'black', 'LineWidth', 2.5);
   
    %fill colour
            k=1;
            flag=1;
            x(1)=0;
            h=1;
            while k<=length(inputs)
                if k>1
                    comp=(limBot(k)+limBot(k-1))/2;
                else
                    comp=frInputs(k)/2;
                end
                if limTop>limBot(k)
                    if limTop > comp
                        if k>1
                            m=(comp-limBot(k-1))/0.05;
                            x(k+1)=(limTop-limBot(k-1))/m;
                        else
                            m=(comp-comp*2)/0.05;
                            x(k+1)=(limTop-(comp*2-limBot(k)))/m;
                        end
                        %m=(comp-comp*2)/0.05;
                        %x(k+1)=(limTop-(comp*2-limBot(k)))/m;
                        patch([x(k+1) 0.05 newPos newPos],[limTop comp comp limTop], colour(length(losses)+1,:),'EdgeColor','none');
                        limTop_old(h)=limTop;
                        h=h+1;
                        limTop=comp;
                    else
                        m=(comp-limBot(k))/0.05;
                        x(k+1)=(limTop-limBot(k))/m;
                        patch([x(k+1) 0 newPos newPos],[limTop limBot(k) limBot(k) limTop], colour(length(losses)+1,:),'EdgeColor','none');
                        k=k+1;
                        limTop_old(h)=limTop;
                        h=h+1;
                        limTop=limBot(k-1);
                    end
                elseif limTop > limBot(k)
                    %is the first input complete
                    patch([0 x(k) newPos newPos],[limBot(k) limTop limTop limBot(k)], colour(length(losses)+1,:),'EdgeColor','none');
                    arcIy(1)=limBot(k);
                    x(k)=0;
                    k=k+1;
               else
                    k=k+1;
                end
            end
        end
    if(length(inputs)>1)
        patch([0.05 newPos newPos 0],[(limBot(end)+limBot(end-1))/2 (limBot(end)+limBot(end-1))/2 limBot(end) limBot(end)], colour(length(losses)+1,:),'EdgeColor','none');
        limTop = limTop_old(1);
    else
        %patch([0.05 newPos newPos 0],[frInputs/2 frInputs/2 limBot(end) limBot(end)], colour(length(losses)+1,:),'EdgeColor','none');
        limTop = limTop_old(1);
    end
    %draw final arrowhead for the output%
    
    line([newPos newPos newPos+max(0.04, 0.8*(limTop-limBot(end))) newPos newPos], [limBot(end), limBot(end) - max(0.015, (limTop+limBot(end))/3), (limTop+limBot(end))/2, limTop + max(0.015, (limTop+limBot(end))/3), limTop], 'Color', 'black', 'LineWidth', 2.5);
   
    %fill colour
    patch([newPos newPos newPos+max(0.04, 0.8*(limTop-limBot(end))) newPos newPos], [limBot(end), limBot(end) - max(0.015, (limTop+limBot(end))/3), (limTop+limBot(end))/2, limTop + max(0.015, (limTop+limBot(end))/3), limTop], colour(length(losses)+1,:),'EdgeColor','none');
    %save final tip position%
    
    newPos = newPos + 0.8*(limTop - limBot(end));
    
    %draw back edge of input arrow%
    for i=1:(length(inputs)-1)
        line([0 0.4], [limBot(i) limBot(i)], 'Color', 'black', 'LineWidth', 1.5);
    end
    %determine overall ins and outs%
    outputFinal = sum(inputs) - sum(losses);
    inputFinal = sum(inputs);
 
    %create the label for the overall output arrow%
    endText = sprintf('%s\n%.0f [%s] %.1f [%%]',labels{length(losses)+length(inputs)+1}, outputFinal, unit,100*outputFinal/inputFinal);
    fontsize = min(12, 10 + ceil((1-sum(frLosses)-0.1)/0.05));
    
    %draw text for the overall output arrow%
    text(newPos + 0.05, (limTop+limBot(end))/2, endText, 'FontSize', fontsize);
    
    %set correct aspect ratio%
    axis equal;
    
    %set correct axis limits%
    set(gca,'YLim',[frInputs(1)-sum(frInputs)-0.4, frInputs(1)+frLosses(1)+0.4]);
    set(gca,'XLim',[-0.15, newPos + 0.1]);
end