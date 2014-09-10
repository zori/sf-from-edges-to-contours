/*******************************************************************************
* Structured Edge Detection Toolbox      Version 1.00
* Copyright 2013 Piotr Dollar.  [pdollar-at-microsoft.com]
* Please email me if you find bugs, or have suggestions or questions!
* Licensed under the MSR-LA Full Rights License [see license.txt]
*******************************************************************************/
#include <mex.h>
#include <math.h>
#include <stdlib.h>
#ifdef USEOMP
#include <omp.h>
#endif

typedef unsigned int uint32;
typedef unsigned short uint16;
#define min(x,y) ((x) < (y) ? (x) : (y))

// construct lookup array for mapping fids to channel indices
uint32* buildLookup( int *dims, int w ) {
  int c, r, z;
  int n=w*w*dims[2]; // dims[2] is nEdgeBins
  uint32 *cids=new uint32[n];
  n=0;
  for(z=0; z<dims[2]; z++) { // z - edge bins index
    for(c=0; c<w; c++) {    // c - column index
      for(r=0; r<w; r++) {  // r - row index
        cids[n++] = z*dims[0]*dims[1] + c*dims[0] + r;
        // printf("%u ", cids[n-1]);
      }
      // printf("\n");
    }
  }
  return cids;
}

// construct lookup arrays for mapping fids for self-similarity channel
void buildLookupSs( uint32 *&cids1, uint32 *&cids2, int *dims, int w, int m ) {
  int i, j, z, z1, c, r; int locs[1024];
  int m2=m*m, n=m2*(m2-1)/2*dims[2], s=int(w/m/2.0+.5);
  cids1 = new uint32[n]; cids2 = new uint32[n]; n=0;
  for(i=0; i<m; i++) locs[i]=uint32((i+1)*(w+2*s-1)/(m+1.0)-s+.5);
  for(z=0; z<dims[2]; z++) for(i=0; i<m2; i++) for(j=i+1; j<m2; j++) {
    z1=z*dims[0]*dims[1]; n++;
    r=i%m; c=(i-r)/m; cids1[n-1]= z1 + locs[c]*dims[0] + locs[r];
    r=j%m; c=(j-r)/m; cids2[n-1]= z1 + locs[c]*dims[0] + locs[r];
  }
}

// compute edge maps for the location represented by c - column and r - row; changes the edges matrix E
void computeEdges(const int c, const int r, const int w1, const int h1,
      const int nTreesEval, const int stride, const int h2,
      float * const E, const uint32 *ind, const uint16 *eBins, const uint32 *eBnds, const uint32 *eids) {
  for( int t=0; t<nTreesEval; t++ ) {
    uint32 k = ind[ r + c*h1 + t*h1*w1 ];
    float *E1 = E + (r*stride) + (c*stride)*h2;
    int b0=eBnds[k], b1=eBnds[k+1]; if(b0==b1) continue;
    for( int b=b0; b<b1; b++ )
      E1[eids[eBins[b]]]++; // because of the way eids indexes patches, c and r are the 0-based x and y coords of the upper-left corner of the 16 x 16 border patch
  }
}

// [E,ind] = mexFunction(model,chns,chnsSs) - helper for edgesDetect.m; compute all edge maps
// [E,ind] = mexFunction(model,chns,chnsSs,x1,y1) - helper for edgesDetect.m; compute edge maps only for the given pixel location
void mexFunction( int nl, mxArray *pl[], int nr, const mxArray *pr[] )
{
  // get inputs
  mxArray *model = (mxArray*) pr[0];
  float *chns = (float*) mxGetData(pr[1]);
  float *chnsSs = (float*) mxGetData(pr[2]);
  bool allPxs = nr == 3;
  // the input parameters are indices that come from matlab; they are 1-based and the following code works with 0-based indices
  const int x1 = allPxs ? 0 : (int) mxGetScalar(pr[3])-1;
  const int y1 = allPxs ? 0 : (int) mxGetScalar(pr[4])-1;

  // extract relevant fields from model and options
  float *thrs = (float*) mxGetData(mxGetField(model,0,"thrs"));
  uint32 *fids = (uint32*) mxGetData(mxGetField(model,0,"fids"));
  uint32 *child = (uint32*) mxGetData(mxGetField(model,0,"child"));
  uint16 *eBins = (uint16*) mxGetData(mxGetField(model,0,"eBins"));
  uint32 *eBnds = (uint32*) mxGetData(mxGetField(model,0,"eBnds"));
  mxArray *opts = mxGetField(model,0,"opts");
  const int shrink = (int) mxGetScalar(mxGetField(opts,0,"shrink"));
  const int imWidth = (int) mxGetScalar(mxGetField(opts,0,"imWidth"));
  const int gtWidth = (int) mxGetScalar(mxGetField(opts,0,"gtWidth"));
  const int nChns = (int) mxGetScalar(mxGetField(opts,0,"nChns"));
  const int nCells = (int) mxGetScalar(mxGetField(opts,0,"nCells"));
  const uint32 nChnFtrs = (uint32) mxGetScalar(mxGetField(opts,0,"nChnFtrs"));
  const int nEdgeBins = (int) mxGetScalar(mxGetField(opts,0,"nEdgeBins"));
  const int stride = (int) mxGetScalar(mxGetField(opts,0,"stride"));
  const int nTreesEval = (int) mxGetScalar(mxGetField(opts,0,"nTreesEval"));
  int nThreads = (int) mxGetScalar(mxGetField(opts,0,"nThreads"));

  // get dimensions and constants
  const mwSize *chnsSize = mxGetDimensions(pr[1]);
  const int h = (int) chnsSize[0]*shrink;
  const int w = (int) chnsSize[1]*shrink;
  const mwSize *fidsSize = mxGetDimensions(mxGetField(model,0,"fids"));
  const int nTreeNodes = (int) fidsSize[0];
  const int nTrees = (int) fidsSize[1];
  const int h1 = (int) ceil(double(h-imWidth)/stride);
  const int w1 = (int) ceil(double(w-imWidth)/stride);
  const int h2 = h1*stride+gtWidth;
  const int w2 = w1*stride+gtWidth;
  const int chnDims[3] = {h/shrink,w/shrink,nChns};
  const int indDims[3] = {h1,w1,nTreesEval};
  const int outDims[3] = {h2,w2,nEdgeBins};

  // construct lookup tables
  uint32 *eids, *cids, *cids1, *cids2;
  eids = buildLookup( (int*)outDims, gtWidth );
  cids = buildLookup( (int*)chnDims, imWidth/shrink );
  buildLookupSs( cids1, cids2, (int*)chnDims, imWidth/shrink, nCells );

  // create outputs
  pl[0] = mxCreateNumericArray(3,outDims,mxSINGLE_CLASS,mxREAL);
  float *E = (float*) mxGetData(pl[0]);
  pl[1] = mxCreateNumericArray(3,indDims,mxUINT32_CLASS,mxREAL);
  // joint leaf-and-tree index for location (pixel lookup) and tree evaluated
  uint32 *ind = (uint32*) mxGetData(pl[1]); // h1 x w1 x nTreesEval matrix

  // apply forest to all patches and store leaf inds
  #ifdef USEOMP
  nThreads = min(nThreads,omp_get_max_threads());
  #pragma omp parallel for num_threads(nThreads)
  #endif
  for( int c=0; c<w1; c++ ) for( int t=0; t<nTreesEval; t++ ) {
    for( int r0=0; r0<2; r0++ ) for( int r=r0; r<h1; r+=2 ) {
      int o = (r*stride/shrink) + (c*stride/shrink)*h/shrink;
      // select tree to evaluate
      int t1 = ((r+c)%2*nTreesEval+t)%nTrees; uint32 k = t1*nTreeNodes;
      while( child[k] ) {
        // compute feature (either channel or self-similarity feature)
        uint32 f = fids[k]; float ftr;
        if( f<nChnFtrs ) ftr = chns[cids[f]+o]; else
          ftr = chnsSs[cids1[f-nChnFtrs]+o]-chnsSs[cids2[f-nChnFtrs]+o];
        // compare ftr to threshold and move left or right accordingly
        if( ftr < thrs[k] ) k = child[k]-1; else k = child[k];
        k += t1*nTreeNodes;
      }
      // store leaf index and update edge maps
      ind[ r + c*h1 + t*h1*w1 ] = k; // ind[r,c,t]; r in [0,h1); c in [0,w1), t in [0,nTreesEval)
    }
  }

  // compute edge maps
  if (allPxs) {
    // iterate the w1*h1 locations, avoiding collisions from parallel executions
    for( int c0=0; c0<gtWidth/stride; c0++ ) {
      #ifdef USEOMP
      #pragma omp parallel for num_threads(nThreads)
      #endif
      for( int c=c0; c<w1; c+=gtWidth/stride ) { // the increment of c, through use of c0 is for parallel execution
        for( int r=0; r<h1; r++ ) {
          computeEdges(c, r, w1, h1, nTreesEval, stride, h2, E, ind, eBins, eBnds, eids);
        }
      }
    }
  } else {
    int c=x1, r=y1;
    computeEdges(c, r, w1, h1, nTreesEval, stride, h2, E, ind, eBins, eBnds, eids);
  }

  delete [] eids; delete [] cids; delete [] cids1; delete [] cids2;
}
