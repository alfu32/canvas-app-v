#include <stdio.h>
int put_at_end(const char* filename,const char* line){
   FILE *fp;
   fp = fopen("fseeko.test.txt","a+");
   int a=0;
   //int a=fseek( fp, 0, SEEK_END );
   int b=fputs(line, fp);
   int c=fclose(fp);
   return a*100+b*10+c;
}
int main () {
   const char* fn="fseeko.test.txt";
   int r0=put_at_end(fn,"This is tutorialspoint.com\n");
   int r1=put_at_end(fn,"adding C Programming Language\n");
   int r2=put_at_end(fn,"adding Go Programming Language\n");
   int r3=put_at_end(fn,"adding V Programming Language\n");

   return(0);
}
