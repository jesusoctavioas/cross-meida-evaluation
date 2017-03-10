classdef actSoftmax < IAct
    properties
    end
    
    methods
        function obj = actSoftmax()
        end
        
        function y = apply(obj, x)
            onGpu = false;
            if isa(x, 'parallel.gpu.GPUArray')
                onGpu = true;
                x = gather(x);
            end
            
            % It works only for 2D outputs!
            nout = size(x,2);
            % Ensure that sum(exp(x), 2) does not overflow
            maxcut = log(realmax(class(x))) - log(nout);
            % Ensure that exp(x) > 0
            mincut = log(realmin(class(x)));
            x = min(x, maxcut);
            x = max(x, mincut);
            temp = exp(x);
            y = bsxfun(@rdivide, temp, sum(temp, 2));
            
            % Ensure that log(y) is computable
            y(y<realmin) = realmin;
            
            if onGpu 
                y = gpuArray(y);
            end
        end
        
        function y = deriv1(obj, x, da)
            y = da.*x - x.*(sum(x.*da,2)*ones(1,size(x,2)));
        end
        
        function y = deriv2(obj, x, dx, da, xprime)
            if nargin < 5
                xprime = obj.deriv1(x, dx);
            end
            
            if isscalar(dx)
                dx = ones(size(x));
            end
            
            if isscalar(da)
                da = ones(size(x));
            end
            
            y = obj.g_dsoftmax(xprime,x,da);
        end
        
    end
    methods (Access = private)
        function [g_y, y]= g_dsoftmax(g_x, x, da)
            % Generated by ADiMat 0.5.6-2921
            % Copyright 2009, 2010 Johannes Willkomm, Institute for Scientific Computing,
            % Copyright 2001-2008 Andre Vehreschild, Institute for Scientific Computing,
            % RWTH Aachen University, 52056 Aachen, Germany.
            % Visit us on the web at http://sc.rwth-aachen.de/adimat
            % Report bugs to willkomm@sc.rwth-aachen.de
            
            g_tmp_dsoftmax_00000= da.* g_x;
            tmp_dsoftmax_00000= da.* x;
            g_tmp_dsoftmax_00001= g_x.* da;
            tmp_dsoftmax_00001= x.* da;
            g_tmp_sum_00000= sum(g_tmp_dsoftmax_00001, 2);
            tmp_sum_00000= sum(tmp_dsoftmax_00001, 2);
            % Identifier 'size' is ignored during differentiation.
            tmp_size_00000= size(x, 2);
            g_tmp_size_00000= zeros(size(tmp_size_00000));
            g_tmp_ones_00000= zeros(1, tmp_size_00000);
            tmp_ones_00000= ones(1, tmp_size_00000);
            g_tmp_dsoftmax_00002= g_tmp_sum_00000* tmp_ones_00000+ tmp_sum_00000* g_tmp_ones_00000;
            tmp_dsoftmax_00002= tmp_sum_00000* tmp_ones_00000;
            g_tmp_dsoftmax_00003= g_x.* tmp_dsoftmax_00002+ x.* g_tmp_dsoftmax_00002;
            tmp_dsoftmax_00003= x.* tmp_dsoftmax_00002;
            g_y= g_tmp_dsoftmax_00000- g_tmp_dsoftmax_00003;
            y= tmp_dsoftmax_00000- tmp_dsoftmax_00003;
        end
    end
end
