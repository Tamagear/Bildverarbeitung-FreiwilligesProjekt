function y=postwork(I, cells, filterType, filterAmount)
    y=0;
    drawcellcircles(cells);
    switch(filterType)
        case PostworkFilterType.NONE
            
        case PostworkFilterType.AMOUNT_MIN_COIN_COUNT

        case PostworkFilterType.AMOUNT_MIN_COIN_VALUE

        case PostworkFilterType.MIN_AMOUNT

        case PostworkFilterType.MAX_AMOUNT

    end
end

function y=colorize(I, x, y, r, color)
    th = 0:pi/50:2*pi;
    xunit = r*cos(th) + x;
    yunit = r*sin(th) + y;    
    y = plot(xunit, yunit);
    % Wie bekommen wir das ordentlich gezeichnet? Am liebsten: Eigenes,
    % transparentes Bild
end

function y=drawcellcircles(cells)
    centers = cells(:, 3:4)
    radii = cells(:, 5)
    y = viscircles(centers, radii);
    % Siehe colorize
end

function y=valueColor(value)
    switch (value)
        case 0.0
            y = 'w';
        case 0.01
            y = '#0072BD';
        case 0.02
            y = '#D95319';
        case 0.05
            y = '#EDB120';
        case 0.1
            y = '#7E2F8E';
        case 0.2
            y = '#77AC30';
        case 0.5
            y = '#4DBEE';
        case 1
            y = '#A2142F';
        case 2
            y = '#FF6A5E';
    end
end