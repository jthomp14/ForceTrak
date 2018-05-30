function[cdat,d_cdat,dd_cdat] = WindowSpline(tbar,xbar,polyorder)      
%General polynomial (mth degree) regression windowing to find the 1st or
%second derivative for some data set
%John Thompson
%MAE4020 - Spring 2018 - HW#2
%************************************************************************
%This function utilizes "pollyfitter.m"
%INPUTS:
%   - t = time data
%   - coorddata = x or y position coordinates
%   - Poly order = any order polynomial for the regression window
%OUTPUTS:
%   - cdat = 
%   - d_cdat = 
%   - dd_cdat = 
%
%CONSIDER MAKING THIS OPTIMIZE THE ERROR TO FIND THE BEST
%WINDOW AND ORDER AUTOMATICALLY!?!?!?!?!?!? <------------------------------ WOULD BE SUPER NEAT
%------------------------------------------------------------------------

       
        %BEGIN AUXILARY FUNCTIONS:
        function [coeff] = polyfitter(tbar,xbar,polyorder)
            %General polynomial (mth degree) regression line fit:
            %John Thompson
            %MAE4020 - Spring 2018 - HW#2
            %************************************************************
            %Algorithm details
            %for any n data points model regression polynomial:
            %x(t) = a0 + a1*t + a2*t^2 + ... + am*t^m

            %error:
            %ei = yi - (a0 + a1*ti + a2*ti^2 + ... + am*ti^m)
            %s = sum_i^n (ei)^2
            %Take partials wrt the coefficients a0, a1, ..., am
            %set equal to zero and solve system of equations...

            %coefficients, a(i), are returned in the following order:
            %a(0)t^0, a(1)t^1, a(2)t^2, ..., a(m-1)t^(m-1), a(m)t^m,

            %NOTE! This algorithm breaks down when the order is near the 
            %total number of data points.  Checked against MATLAB's
            %built-in polyfit and results vary as this happens.
            %Thus, to ensure good approximation, more data points 
            %seems better tha less.

            %Deal with warnings for too high of order and too little 
            %data points turn matrix singularity warning off, 
            %initiaze my warning if necessary instead
            warning('off','MATLAB:nearlySingularMatrix')
            if polyorder >= length(tbar)*.6
                str = sprintf('The order of the polynomial is close to the number of data points.\nRESULTS MAY BE INACCURATE.\nIt is reccomended to reduce the order.');
                warning(str)
            end

         
            %Begin algorithm:
            %-----------------------------
            %initialize variables
            A = zeros(polyorder+1);
            b = zeros(polyorder+1,1);
            l = 0;

            %Build system of equations
            for ii = 1:polyorder+1
                l = ii-1;
                for jj = 1:polyorder+1
                    for kk = 1:length(tbar)
                        if jj == 1
                            b(ii,1) = b(ii,1) + xbar(kk)*(tbar(kk)^(l));
                        end
                        A(ii,jj) = A(ii,jj) + tbar(kk)^(l);
                    end
                    l = l+1;
                end
            end

            %solve system for coefficients
            coeff = A\b; %<--- Kramer's rule

            %turn martix singularity warning back on.
            warning('on','MATLAB:nearlySingularMatrix')
        end
        %-----------------------------------------------------------------
        %-----------------------------------------------------------------
        function [filtered_data] = polyToData(t, coeff)
            %turn coefficients from polyfitter.m into filtered data
            %John Thompson
            %MAE4020 - Spring 2018 - HW#2
            %*************************************************************
            %This is intended to work with the function "polyfitterHW2.m"
            %as it assumes a particular coefficient order
            %See Details in "polyfitterHW2.m" on order
            %Note: t data (time must be specified)

            %Begin:
            %loop through and generate plot data with
            filtered_data = zeros(length(t),1);
            for iii = 1:length(coeff)
                filtered_data = filtered_data + coeff(iii)* t.^(iii-1);
            end
        end
        %-----------------------------------------------------------------



    %--------------------------------------------------------------------
    %Begin Main-Body of Function/Algorithm:
    %--------------------------------------------------------------------
    %Windowsize must be odd
    windowsize = 13;
    n = length(xbar);
    %initialize  Variables:
    cdat = zeros(n,1);              %Position data
    d_cdat = zeros(n,1);            %First derivative
    dd_cdat = zeros(n,1);           %Second derivative
    iter = (windowsize/2 - 0.5);    %+/- of window

    %Run windowing loop, get coefficients, apply derivatives
    for i = 1:length(xbar)
        
        %Fist aux points use a smaller set
        if i <= iter
            acoeff= polyfitter(tbar(1:iter+i),xbar(1:iter+i),polyorder);
            
        %Last aux points use a smaller set
        elseif i >= n - iter
            acoeff =polyfitter(tbar(i-iter:n),xbar(i-iter:n),polyorder);
            
        %full window
        else
            acoeff = polyfitter(tbar((i-iter):(i+iter)),xbar((i-iter):(i+iter)),polyorder);
       
        end
        
        %Get filtered data:
        cdat(i,1) = polyToData(tbar(i), acoeff);


        %------------------------------------
        %generate derivative data
        %Consider: 3rd order
        %f(x) = a0x^0 + a1x^1 + a2x^2 + a3x^3
        %f'(x) = a1x^0 + 2*a2x^1 + 3*a3x^2
        %f''(x) = 2*a2x^0 + 3*2*a3x^1
        %------------------------------------
        %algorithm: for nth order first derivative:
        %a = [a1, a2, a3, a4, ..., an]
        %i = 1:  f' = i*a(i)
        %i = 2:  f' = f' + (i)*a(i)*x^(i-1)
        %i = 3:  f' = f' + (i)*a(i)*x(^i-1)
        %....                        sum_i=1,to:n [i*a(i)*x^(i-1)]
        %First derivative:
        for j = 1:length(acoeff)-1
            d_cdat(i,1) = d_cdat(i,1) + j*acoeff(j+1) *tbar(i)^(j-1);
        end
        
        %algorithm: for nth order second derivative:
        %i = 2:  f'' = (i)*(i-1)*a(i)*x^(i-2)
        %i = 3:  f'' = f'' + (i)*(i-1)*a(i)*x^(i-2)
        %....                        sum_i=2,to:n [i*(i-1)*a(i)*x^(i-2)]
        %Second derivative:
        for j = 2:length(acoeff)-1 %<--- second derivative
            dd_cdat(i,1) = dd_cdat(i,1) + (j)*(j-1)*acoeff(j+1) * tbar(i)^(j-2);
        end
    end
        
        
        
end

    
