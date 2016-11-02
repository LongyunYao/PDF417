/**
rho: 霍夫空间的r粒度大小 
theta: 旋转角度的粒度 
threshold:直线上有多少个点的阈值 
lines：输出lines结果 
linesMax：lines的最大个数
*/
static void  
icvHoughLinesStandard( const CvMat* img, float rho, float theta,  
                       int threshold, CvSeq *lines, int linesMax )  
{  
    cv::AutoBuffer<int> _accum, _sort_buf;  
    cv::AutoBuffer<float> _tabSin, _tabCos;  
  
    const uchar* image;  
    int step, width, height;  
    int numangle, numrho;  
    int total = 0;  
    float ang;  
    int r, n;  
    int i, j;  
    float irho = 1 / rho;  
    double scale;  
  
    CV_Assert( CV_IS_MAT(img) && CV_MAT_TYPE(img->type) == CV_8UC1 );  
  
    image = img->data.ptr;  
    step = img->step;  
    width = img->cols;  
    height = img->rows;  
  
    numangle = round(CV_PI / theta);    // 霍夫空间，角度方向的大小  
    numrho = round(((width + height) * 2 + 1) / rho);  // r的空间范围  
  
    _accum.allocate((numangle+2) * (numrho+2));  
    _sort_buf.allocate(numangle * numrho);  
    _tabSin.allocate(numangle);  
    _tabCos.allocate(numangle);  
    int *accum = _accum, *sort_buf = _sort_buf;  
    float *tabSin = _tabSin, *tabCos = _tabCos;  
      
    memset( accum, 0, sizeof(accum[0]) * (numangle+2) * (numrho+2) );  
  
    for( ang = 0, n = 0; n < numangle; ang += theta, n++ ) // 计算正弦曲线的准备工作，查表  
    {  
        tabSin[n] = (float)(sin(ang) * irho);  
        tabCos[n] = (float)(cos(ang) * irho);  
    }  
  
    // stage 1. fill accumulator  
    for( i = 0; i < height; i++ )  
        for( j = 0; j < width; j++ )  
        {  
            if( image[i * step + j] != 0 )      // 将每个非零点，转换为霍夫空间的离散正弦曲线，并统计。  
                for( n = 0; n < numangle; n++ )  
                {  
                    r = round( j * tabCos[n] + i * tabSin[n] );  
                    r += (numrho - 1) / 2;  
                    accum[(n+1) * (numrho+2) + r+1]++;  
                }  
        }  
  
    // stage 2. find local maximums  
    // 霍夫空间，局部最大点，采用四邻域判断，比较。
    //（也可以使8邻域或者更大的方式）, 如果不判断局部最大值，同时选用次大值与最大值，就可能会是两个相邻的直线，但实际上是一条直线。
    //选用最大值，也是去除离散的近似计算带来的误差，或合并近似曲线。  
    for( r = 0; r < numrho; r++ )     
        for( n = 0; n < numangle; n++ )  
        {  
            int base = (n+1) * (numrho+2) + r+1;  
            if( accum[base] > threshold &&  
                accum[base] > accum[base - 1] && accum[base] >= accum[base + 1] &&  
                accum[base] > accum[base - numrho - 2] && accum[base] >= accum[base + numrho + 2] )  
                sort_buf[total++] = base;  
        }  
  
    // stage 3. sort the detected lines by accumulator value
    // 由点的个数排序，依次找出哪些最有可能是直线  
    icvHoughSortDescent32s( sort_buf, total, accum );  
  
    // stage 4. store the first min(total,linesMax) lines to the output buffer  
    linesMax = MIN(linesMax, total);  
    scale = 1./(numrho+2);  
    for( i = 0; i < linesMax; i++ )  // 依据霍夫空间分辨率，计算直线的实际r，theta参数  
    {  
        CvLinePolar line;  
        int idx = sort_buf[i];  
        int n = floor(idx*scale) - 1;  
        int r = idx - (n+1)*(numrho+2) - 1;  
        line.rho = (r - (numrho - 1)*0.5f) * rho;  
        line.angle = n * theta;  
        cvSeqPush( lines, &line );  
    }  
}  