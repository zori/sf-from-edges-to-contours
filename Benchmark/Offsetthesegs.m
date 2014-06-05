function segs=Offsetthesegs(segs,offsetgt,meangtobjs)

increaseattwo=(offsetgt.max-meangtobjs);
increaseatmax=meangtobjs-offsetgt.min;

if (increaseattwo>0)
    for i=numel(segs):-1:2, segs(i+increaseattwo)=segs(i); end
    for i=3:(increaseattwo+1), segs(i)=segs(2); end
end
if (increaseatmax>0)
    maxnsegs=numel(segs);
    segs(maxnsegs+increaseatmax)=segs(maxnsegs);
    for i=0:(increaseatmax-1), segs(i+maxnsegs)=segs(maxnsegs-1); end
end
