% readYUV.m WCC-2008-07-09
% *************************************************************************
% Input: fid ！！ The file pointer of YUV;
%        vInfo ！！ The video info get from the function of 'getYUV';
%        ind ！！ The frame number that will be read.
% Output: frame ！！ The frame structure of YUV.
% *************************************************************************
function frame = readYUV(fid, vInfo, ind);

fr_sz = vInfo.width * vInfo.height;
width = vInfo.width;
height = vInfo.height;

switch vInfo.type
    case 'T420'
        fseek(fid, (ind-1) * fr_sz*3/2, 'bof');
        frame = fread(fid, fr_sz*3/2, 'uchar');
        Y = frame(1 : fr_sz);
        U = frame(fr_sz + 1 : (fr_sz*5/4) );
        V = frame(fr_sz*5/4 + 1 : fr_sz*3/2);
        Y = reshape(Y, width, height);
        U = reshape(U, width/2, height/2);
        V = reshape(V, width/2, height/2);
        Y = Y';
        U = U';
        V = V';
    case 'T422'
        fseek(fid, (ind-1) * fr_sz*2, 'bof');
        frame = fread(fid, fr_sz*2, 'uchar');
        Y = frame(1 : fr_sz);
        U = frame(fr_sz + 1 : (fr_sz*3/2) );
        V = frame(fr_sz*3/2 + 1 : fr_sz*2);
        Y = reshape(Y, width, height);
        Y = Y';
        U = reshape(U, width/2, height);
        U = U';
        V = reshape(V, width/2, height);
        V = V';
    case 'T444'
        fseek(fid, (ind-1) * fr_sz*3, 'bof');
        frame = fread(fid, fr_sz*3, 'uchar');
        Y = frame(1 : fr_sz);
        U = frame(fr_sz + 1 : fr_sz*2 );
        V = frame(fr_sz*2 + 1 : fr_sz*3);
        Y = reshape(Y, width, height);
        Y = Y';
        U = reshape(U, width, heidht);
        U = U';
        V = reshape(V, width, height);
        V = V';
    otherwise
        error('Input video format error!')
end

frame.Y = Y;
frame.U = U;
frame.V = V;

        

