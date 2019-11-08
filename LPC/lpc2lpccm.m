function lpccs=lpc2lpccm(ars,n_lpc,n_lpcc)          % ��LPC��������Ԥ�⵹��ϵ��
frames=size(ars,1);
lpccs=zeros(n_lpcc,frames);
for i=1:frames
    ar=ars(i,:);
    ar=ar';
    lpcc=zeros(n_lpcc,1);
    lpcc(1)=ar(1);                                    % ����n=1��lpcc
    for n=2:n_lpc                                     % ����n=2,...,p��lpcc
      lpcc(n)=ar(n);
      for l=1:n-1
          lpcc(n)=lpcc(n)+ar(l)*lpcc(n-l)*(n-l)/n;
      end
    end

    for n=n_lpc+1:n_lpcc                              % ����n>p��lpcc
        lpcc(n)=0;
        for l=1:n_lpc
            lpcc(n)=lpcc(n)+ar(l)*lpcc(n-l)*(n-l)/n;
        end
    end
    lpcc=-lpcc;
    lpccs(:,i)=lpcc;
end