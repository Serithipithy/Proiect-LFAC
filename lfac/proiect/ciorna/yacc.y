%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

extern FILE* yyin;
extern char* yytext;
extern int yylineno;

struct variabila
{
int valoare_int;
float valoare_float;
char valoare_char;
char* valoare_string;
char* nume;
char* tip_variabila;
_Bool constanta;
_Bool valoare_init;  /* are o valoare initializata*/
};
struct variabila variabile[200];
int v=0;
int v_ant=0; /*folosit pentru a umple symbol_table*/

struct functie
{
char* tip_functie;
char* nume;
char* argumente;
};
struct functie functii[200];
int f=0;
int f_ant=0; /*folosit pentru a umple symbol_table*/

struct array
{
  char* tip_array;
  char* nume;
  int dimensiune1,dimensiune2;
  int vector[300];
  int matrice[300][300];
};
struct array arrays[200];
int a=0; int a_ant=0;

int arrays_declarate(char* nume)
{
     for(int i=0;i<a;i++)
        {
          if(strcmp(arrays[i].nume,nume)==0) return i;
        }
      return -1;
}

void reverse(char s[])
 {
     int i, j;
     char c;

     for (i = 0, j = strlen(s)-1; i<j; i++, j--) {
         c = s[i];
         s[i] = s[j];
         s[j] = c;
     }
}
 void itoa(int n, char s[])
 {
     int i, sign;

     if ((sign = n) < 0)  /* record sign */
         n = -n;          /* make n positive */
     i = 0;
     do {       /* generate digits in reverse order */
         s[i++] = n % 10 + '0';   /* get next digit */
     } while ((n /= 10) > 0);     /* delete it */
     if (sign < 0)
         s[i++] = '-';
     s[i] = '\0';
     reverse(s);
}
void convert_nr(int numar, char* string){
char nr[100];
itoa(numar,nr);
strcat(string,nr);
strcat(string,",");
}
void declarare_array_fara_init(char* tip,char* nume,int dimensiune1,int dimensiune2){

   if(arrays_declarate(nume)!=-1){
   char buffer[256];
   sprintf(buffer,"Array %s este deja declarat",nume);
   yyerror(buffer);
   exit(0);
   }
   arrays[a].tip_array=strdup(tip);
   arrays[a].nume=strdup(nume);
   arrays[a].dimensiune1=dimensiune1;
   arrays[a].dimensiune2=dimensiune2;
   a++;

}

void declarare_array_init(char* tip,char* nume,int dimensiune1,int dimensiune2,char* elemente){
   if(arrays_declarate(nume)!=-1){
   char buffer[256];
   sprintf(buffer,"Array %s este deja declarat",nume);
   yyerror(buffer);
   exit(0);
   }
   arrays[a].tip_array=strdup(tip);
   arrays[a].nume=strdup(nume);
   arrays[a].dimensiune1=dimensiune1;
   arrays[a].dimensiune2=dimensiune2;
   if(arrays[a].dimensiune2>0)
   {
   char copie[2024];
   strcpy (copie,elemente);
   int i=1; int j=1; int l=0;
      while(strlen(copie)>l+1){
              char nr[10]; int k=0;
        while(copie[l]!=',' && strlen(copie) > l){
            nr[k]=copie[l++];k++;
        }
        l++;
        int x;
        strcpy(nr, nr+1);
        nr[strlen(nr)-1]='\0';
        x=atoi(nr);
        if(i>dimensiune1)
        {
           break;
        }
        arrays[a].matrice[i][j]=x;
        if(j>=dimensiune2)
        {
          j=1;
          i++;
        }
        else j++;
      }
   }
   else{
   char copie[2024];
   strcpy (copie,elemente);
   int i=1; int j=0;
   while(strlen(copie)>0){
     char nr[10]; int k=0;
     while(copie[j]!=',' && strlen(copie) > j){
         nr[k]=copie[j++];k++;
     }
     j++;
     int x=9;
     strcpy(nr, nr+1);
     nr[strlen(nr)-1]='\0';
     x=atoi(nr);
     if(i<=dimensiune1){
     arrays[a].vector[i]=x;
     i++;
     }
     else{
     break;
     }
   }
   }
   a++;
}

int variabile_declarate(char* nume)
{
     for(int i=0;i<v;i++)
        {
          if(strcmp(variabile[i].nume,nume)==0) return i;
                  }
      return -1;
}

void declarare_fara_initializare(char* tip_variabila,char* nume,_Bool constanta)
{
      if(variabile_declarate(nume)!=-1)
       {
         char buffer[256];
         sprintf(buffer,"Variabila %s este deja declarata",nume);
         yyerror(buffer);
         exit(0);
       }
     if(constanta==1)
      {
        char buffer[256];
        sprintf(buffer,"Nu puteti declara variabile de tip const %s fara initializare",nume);
        yyerror(buffer);
        exit(0);
       }
     variabile[v].tip_variabila=strdup(tip_variabila);
     variabile[v].nume=strdup(nume);
     variabile[v].valoare_init=0;
     variabile[v].constanta=0;
     v++;
}


void declarare_cu_initializare_int(char* tip_variabila,char*nume,int valoare,_Bool constanta)
{
    if(variabile_declarate(nume)!=-1)
      {
        char buffer[256];
        sprintf(buffer,"Variabila %s este deja declarata",nume);
        yyerror(buffer);
        exit(0);
      }
    if(strcmp(tip_variabila,"int") != 0)
    {
                char buffer[256];
        sprintf(buffer,"Variabila %s este de tip %s, iar valoarea asignata este de tip int.",nume, tip_variabila);
        yyerror(buffer);
        exit(1);
    }
    variabile[v].tip_variabila=strdup(tip_variabila);
    variabile[v].nume=strdup(nume);
        variabile[v].valoare_int=valoare;
    variabile[v].valoare_init=1;
    variabile[v].constanta=constanta;
    v++;
}

void declarare_cu_initializare_float(char* tip_variabila,char*nume,float valoare,_Bool constanta)
{
    if(variabile_declarate(nume)!=-1)
      {
        char buffer[256];
        sprintf(buffer,"Variabila %s este deja declarata",nume);
        yyerror(buffer);
        exit(0);
      }
      if(strcmp(tip_variabila,"float") != 0)
    {
                char buffer[256];
        sprintf(buffer,"Variabila %s este de tip %s, iar valoarea asignata este de tip float.",nume, tip_variabila);
        yyerror(buffer);
        exit(1);
    }
    variabile[v].tip_variabila=strdup(tip_variabila);
    variabile[v].nume=strdup(nume);
    variabile[v].valoare_float=valoare;
    variabile[v].valoare_init=1;
    variabile[v].constanta=constanta;
    v++;
}

void declarare_cu_initializare_char(char* tip_variabila,char*nume,char* valoare,_Bool constanta)
{
    if(variabile_declarate(nume)!=-1)
      {
        char buffer[256];
        sprintf(buffer,"Variabila %s este deja declarata",nume);
        yyerror(buffer);
        exit(0);
      }

        if(strcmp(tip_variabila,"char") != 0)
    {
                char buffer[256];
        sprintf(buffer,"Variabila %s este de tip %s, iar valoarea asignata este de tip char.",nume, tip_variabila);
        yyerror(buffer);
        exit(1);
            }
    variabile[v].tip_variabila=strdup(tip_variabila);
    variabile[v].nume=strdup(nume);
    variabile[v].valoare_char=valoare[1];
    variabile[v].valoare_init=1;
    variabile[v].constanta=constanta;
    v++;
}

void declarare_cu_initializare_string(char* tip_variabila,char*nume,char* valoare,_Bool constanta)
{
    if(variabile_declarate(nume)!=-1)
      {
        char buffer[256];
        sprintf(buffer,"Variabila %s este deja declarata",nume);
        yyerror(buffer);
        exit(0);
      }
    if(strcmp(tip_variabila,"string") != 0)
    {
                char buffer[256];
        sprintf(buffer,"Variabila %s este de tip %s, iar valoarea asignata este de tip string.",nume, tip_variabila);
        yyerror(buffer);
        exit(1);
    }
    variabile[v].tip_variabila=strdup(tip_variabila);
    variabile[v].nume=strdup(nume);
    variabile[v].valoare_string=strdup(valoare);
    variabile[v].valoare_init=1;
    variabile[v].constanta=constanta;
    v++;
}

void declarare_cu_variabila_initializata(char* tip_variabila,char* nume,char*variabila, _Bool constanta)
{
        if(variabile_declarate(nume)!=-1)
    {
        char buffer[256];
        sprintf(buffer,"Variabila %s este deja declarata",nume);
        yyerror(buffer);
        exit(0);
    }
    int pozitie=variabile_declarate(variabila);
    if(pozitie == -1)
        {
                char buffer[256];
                                sprintf(buffer,"Variabila %s nu poate fi initializata cu o variabila nedeclarata",nume);
                yyerror(buffer);
                exit(1);
        }
        if(strcmp(tip_variabila,variabile[pozitie].tip_variabila) != 0)
        {
                char buffer[256];
                sprintf(buffer,"Variabilele %s si %s nu sunt de acelasi tip.",nume,variabile[pozitie].nume);
                yyerror(buffer);
                exit(2);
        }
        if(variabile[pozitie].valoare_init == 0)
        {
                char buffer[256];
                sprintf(buffer,"Variabilele %s nu poate fi initializata deoarece variabila %s nu are inca o valoare initializata.",nume,variabile[pozitie].nume);
                yyerror(buffer);
                exit(3);
        }

        variabile[v].tip_variabila=strdup(tip_variabila);
        variabile[v].nume=strdup(nume);
        variabile[v].valoare_init=1;
        variabile[v].constanta=constanta;
        if(strcmp(tip_variabila,"int") == 0)
        {
                variabile[v].valoare_int=variabile[pozitie].valoare_int;
        }
        else
                if(strcmp(tip_variabila,"float") == 0)
                {
                        variabile[v].valoare_float=variabile[pozitie].valoare_float;
                }
                else
                        if(strcmp(tip_variabila,"char") == 0)
                        {
                                variabile[v].valoare_char=variabile[pozitie].valoare_char;
                        }
                        else
                                {
                                        variabile[v].valoare_string=variabile[pozitie].valoare_string;
                                }
        v++;
}

float valoarea_variabilei(char* nume)
{
    int poz=variabile_declarate(nume);
    if(poz==-1)
    {
       char buffer[256];
       sprintf(buffer,"Variabila %s nu a fost declarata",nume);
       yyerror(buffer);
       exit(0);
    }
    if(variabile[poz].valoare_init==0)
    {
       char buffer[256];
       sprintf(buffer,"Variabila %s nu are nicio valoare",nume);
       yyerror(buffer);
       exit(0);
    }
    if(strcmp(variabile[poz].tip_variabila,"int") == 0)
        {
                return variabile[poz].valoare_int;
        }
        else
   {    if(strcmp(variabile[poz].tip_variabila,"float") == 0)
                {
                        return variabile[poz].valoare_float;
                }
    }
}

void asignare_valoare(char* nume,float valoare)
{
        int pozitie = variabile_declarate(nume);

        if(pozitie == -1)
        {
           char buffer[256];
       sprintf(buffer,"Variabila %s nu a fost declarata",nume);
       yyerror(buffer);
       exit(0);
        }

        if(variabile[pozitie].constanta == 1)
        {
           char buffer[256];
       sprintf(buffer,"Nu se poate asigna o noua valoarea variabile constante %s.",nume);
       yyerror(buffer);
       exit(1);
        }
            /* nu stiu cum sa inglobez toate valorile, asa ca am dat float in caz de orice */
    if(strcmp(variabile[pozitie].tip_variabila,"float") != 0 &&
     strcmp(variabile[pozitie].tip_variabila,"int") != 0)
     {
        char buffer[256];
        sprintf(buffer,"Nu se poate asigna o valoare numerica variabilei %s.",nume);
        yyerror(buffer);
        exit(2);
     }

     if(strcmp(variabile[pozitie].tip_variabila,"float") == 0)
     {
        variabile[pozitie].valoare_float=valoare;
        variabile[pozitie].valoare_init=1;
     }
     else
     {
        variabile[pozitie].valoare_int=valoare;
        variabile[pozitie].valoare_init=1;
     }

}
int functii_declarate(char* nume,char* args)
{
    for(int i=0;i<f;i++)
    {
       if((strcmp(functii[i].nume,nume)==0)&&(strcmp(functii[i].argumente,args))) return i;
    }
    return -1;
}
void declarare_functie(char* tip, char* nume,char* args )
{
    if(functii_declarate(nume,args)!=-1)
    {
       char buffer[200];
       sprintf(buffer,"Nu puteti declara 2 functii %s cu acelasi nume",nume);
       yyerror(buffer);
       exit(0);
    }
    functii[f].tip_functie=strdup(tip);
    functii[f].nume=strdup(nume);
    functii[f].argumente=strdup(args);
    f++;
}

void simbol(char* scop){
FILE* g =fopen("symbol_table.txt","a");
fprintf(g,"Variabile declarate %s: \n",scop);
if ( v-v_ant != 0 ){
for(int i=v_ant;i<v;i++) {
   if(variabile[i].valoare_init){
      if(strstr(variabile[i].tip_variabila,"int")) fprintf(g,"<%s> %s %d \n",variabile[i].tip_variabila,variabile[i].nume,variabile[i].valoare_int);
      if(strstr(variabile[i].tip_variabila,"float")) fprintf(g,"<%s> %s %.6f \n",variabile[i].tip_variabila,variabile[i].nume,variabile[i].valoare_float);
      if(strstr(variabile[i].tip_variabila,"char")) fprintf(g,"<%s> %s %c \n",variabile[i].tip_variabila,variabile[i].nume,variabile[i].valoare_char);
      if(strstr(variabile[i].tip_variabila,"string")) fprintf(g,"<%s> %s %s \n",variabile[i].tip_variabila,variabile[i].nume,variabile[i].valoare_string);
     }
    else{
     fprintf(g,"<%s> %s \n",variabile[i].tip_variabila,variabile[i].nume);
    }
}
}
else{
  fprintf(g,"Nu exista variabile declarate %s.\n",scop);
  }
v_ant=v;
fprintf(g,"\n");
if(f-f_ant != 0){
fprintf(g,"Functii declarate %s: \n",scop);
 for(int i=f_ant;i<f;i++){
    fprintf(g,"<%s> %s %s \n",functii[i].tip_functie,functii[i].nume,functii[i].argumente);
}
}
else{
  fprintf(g,"Nu exista functii declarate %s.\n",scop);
  }
f_ant=f;
fprintf(g,"\n");
if( a-a_ant != 0){
fprintf(g,"Arrays declarate %s: \n",scop);
 for(int i=a_ant;i<a;i++){
 if(arrays[i].dimensiune2==0)
 {
 int j;
 fprintf(g,"<%s> %s [%d] = {",arrays[i].tip_array,arrays[i].nume,arrays[i].dimensiune1);
 for(j=1;j<arrays[i].dimensiune1;j++)
 { fprintf(g," %d,",arrays[i].vector[j]);}
 fprintf(g," %d }\n",arrays[i].vector[j]);
 }
    else{
    fprintf(g,"<%s> %s [%d][%d] = \n",arrays[i].tip_array,arrays[i].nume,arrays[i].dimensiune1,arrays[i].dimensiune2);
    int j,k;
    fprintf(g,"{");
    for(j=1;j<= arrays[i].dimensiune1;j++)
    {
       for(k=1;k<=arrays[i].dimensiune2;k++)
       {
       fprintf(g," %d,",arrays[i].matrice[j][k]);
       }
       if(j<arrays[i].dimensiune1)
       {fprintf(g,"\n");}
    }
    fprintf(g,"}");
    }
    fprintf(g,"\n");
}
}
else{
  fprintf(g,"Nu exista arrays declarate %s.\n",scop);
  }
a_ant=a;
fprintf(g,"\n");
fclose(g);
}

void Eval(int a){
printf("Valoarea expresiei este: %d\n",a);
}

void verif_int(int a,float b){
   int rezultat;
   rezultat=b*100-a*100;
   if(rezultat==0) Eval(a);
}

int valoare_array(char* nume, int dimensiune1, int dimensiune2){
  int poz= arrays_declarate(nume);
  if(poz==-1){
   char buffer[256];
   sprintf(buffer,"Array %s este deja declarat",nume);
   yyerror(buffer);
   exit(0);
   }

   if (dimensiune2 == 0){
      if(dimensiune1 <= arrays[poz].dimensiune1 && dimensiune1 > 0) return arrays[poz].vector[dimensiune1];
   }
   else {
    if(dimensiune1 <= arrays[poz].dimensiune1 && dimensiune1 > 0 && dimensiune2 <= arrays[poz].dimensiune2 && dimensiune2 > 0)
      return arrays[poz].matrice[dimensiune1][dimensiune2];
   }
}


%}

%token BOOL BGIN CONST END IF THEN ELSE ENDIF WHILE DO ENDWHILE FOR THENDO ENDFOR CLASS AND OR
%token BOOLEQUAL ASSIGN EQUAL NOT NEG LESS LESSEQUAL GREAT GREATEQUAL PLUS MINUS MULT DIVIDE
%token RPARAN LPARAN BROPEN BRCLOSE AOPEN ACLOSE SEMICOLON COMMA TIP ID INTEGER CHAR FLOAT STRING NR

%start compilator

%left SEMICOLON
%left OR AND
%left PLUS MINUS
%left MULT DIVIDE
%left LPARAN RPARAN

%union
{
    int num;
    float fl;
    char* str;
}

%type <num> INTEGER
%type <fl> FLOAT operatie operand
%type <str> TIP ID CHAR STRING BOOL NR signatura parametrii elemente

%%

compilator: program {printf("program corect sintactic \n");}
          ;

program: global main
       | main
       ;
global : clase functii declaratii {simbol("global");}
       | functii declaratii {simbol("global");}
       | clase functii
       | clase declaratii
       | clase
       | functii
       | declaratii
       ;

functii: TIP ID signatura AOPEN blocuri ACLOSE {declarare_functie($1,$2,$3);}
       ;

clase: clasa
     | clase SEMICOLON clasa
     ;
clasa: CLASS ID AOPEN declaratii ACLOSE SEMICOLON {simbol("in clase");}
     ;

main:BGIN AOPEN blocuri ACLOSE END {simbol("local");}
    ;

declaratii:declaratie
                | declaratii declaratie
                ;

declaratie: TIP ID SEMICOLON /*int a; sau int a,b,c;//functie de declarare fara valoare*/ {declarare_fara_initializare($1,$2,0);}
          | TIP ID ASSIGN INTEGER SEMICOLON /*functie de declarare cu o valoare*/{declarare_cu_initializare_int($1,$2,$4,0);}
          | TIP ID ASSIGN FLOAT SEMICOLON {declarare_cu_initializare_float($1,$2,$4,0);}
          | TIP ID ASSIGN STRING SEMICOLON {declarare_cu_initializare_string($1,$2,$4,0);}
          | TIP ID ASSIGN CHAR SEMICOLON {declarare_cu_initializare_char($1,$2,$4,0);}
          | TIP ID ASSIGN ID SEMICOLON {declarare_cu_variabila_initializata($1,$2,$4,0);}
          | CONST TIP ID SEMICOLON {declarare_fara_initializare($2,$3,1);}
          | CONST TIP ID ASSIGN INTEGER SEMICOLON {declarare_cu_initializare_int($2,$3,$5,1);}
          | CONST TIP ID ASSIGN FLOAT SEMICOLON {declarare_cu_initializare_float($2,$3,$5,1);}
          | CONST TIP ID ASSIGN ID SEMICOLON {declarare_cu_variabila_initializata($2,$3,$5,1);}
          | TIP ID signatura /* pt functii si clase*/{declarare_functie($1,$2,$3);}
          | array SEMICOLON
                ;
array:TIP ID BROPEN INTEGER BRCLOSE{declarare_array_fara_init($1,$2,$4,0);}
     |TIP ID BROPEN INTEGER BRCLOSE BROPEN INTEGER BRCLOSE {declarare_array_fara_init($1,$2,$4,$7);}
     |TIP ID BROPEN INTEGER BRCLOSE ASSIGN AOPEN elemente ACLOSE {declarare_array_init($1,$2,$4,0,$8);}
     |TIP ID BROPEN INTEGER BRCLOSE BROPEN INTEGER BRCLOSE ASSIGN AOPEN elemente ACLOSE {declarare_array_init($1,$2,$4,$7,$11);}
     ;
elemente: NR {$$ = $1;}
        | elemente COMMA NR {$$ = $1; strcat($$,",");strcat($$,$3);}
        ;
signatura: LPARAN RPARAN { $$=malloc(200); $$[0]=0;}
           | LPARAN parametrii RPARAN { $$ = $2; }
           ;

parametrii: TIP ID { $$ = $1; strcat($$,", "); }
                | parametrii COMMA TIP ID  { $$ = $1; strcat($$,$3); }
          ;

blocuri: bloc
       | blocuri bloc
       ;

bloc: FOR LPARAN conditie_for RPARAN THENDO AOPEN operatii ACLOSE ENDFOR
   | IF LPARAN conditii RPARAN THEN AOPEN operatii ACLOSE ENDIF
   | IF LPARAN conditii RPARAN THEN AOPEN operatii ACLOSE ELSE AOPEN operatii ACLOSE ENDIF
   | WHILE LPARAN conditii RPARAN DO AOPEN operatii ACLOSE ENDWHILE
   | operatii
   | declaratie
              ;

conditii: operand
      | BOOL
      | NOT operand
      | operand BOOLEQUAL operand
      | operand LESSEQUAL operand
     | operand GREATEQUAL operand
     | operand LESS operand
     | operand GREAT operand
     | operand NEG operand
     | conditii AND conditii
     | conditii OR conditii
     ;
operand: ID {$$=valoarea_variabilei($1);}
       | ID BROPEN INTEGER BRCLOSE {$$=valoare_array($1,$3,0);}
       | ID BROPEN INTEGER BRCLOSE BROPEN INTEGER BRCLOSE {$$=valoare_array($1,$3,$6);}
       | INTEGER {$$ = $1;}
       | FLOAT {$$ = $1;}
       ;
operatii: tip_operatie SEMICOLON
       | operatii SEMICOLON tip_operatie SEMICOLON
       ;
tip_operatie: ID ASSIGN operatie {asignare_valoare($1,$3);}
          ;
operatie:operand
       |operatie PLUS operatie {$$ = $1 + $3; verif_int($$,$$);}
       |operatie MINUS operatie {$$ = $1 - $3;verif_int($$,$$);}
       |operatie MULT operatie {$$ = $1 * $3;verif_int($$,$$);}
       |operatie DIVIDE operatie {$$ = $1 / $3;verif_int($$,$$);}
       ;
conditie_for:statement SEMICOLON conditii SEMICOLON ID ASSIGN operatie
           ;
statement:ID ASSIGN operand {asignare_valoare($1,$3);}
        ;
%%
void yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
yyin=fopen(argv[1],"r");
FILE* g = fopen("symbol_table.txt", "w");
yyparse();
fclose(g);
}
