#define MAX_INPUT_LENGTH 163840
#define GAP      10
#define MISMATCH 1
#define OPENGAP  3
#define COMBINATIONMX 500
#define LENGTH_PER_LINE 100
/*
#define BLASTALL "nice -2 /home/daddy/BLAST/blastall"
#define FASTADIR "nice -2 /home/daddy/FASTA"
#define BLASTDBENV "/home/daddy/dt/blast"
#define NCBIENV "/bioinfnv/software/ncbisw/ncbi"
#define BLASTMATENV "/home/daddy/CHIN_LIB/matrix"
#define BLASTFILTERENV "/home/daddy/CHIN_LIB/filter"
#define MATRIX_NT "/home/daddy/CHIN_LIB/matrix/nt"
#define MATRIX_AA "/home/daddy/CHIN_LIB/matrix/aa"
*/
#define FASTA "fasta34_t"
#define FASTX "fastx34_t"
#define FASTY "fasty34_t"
#define TFASTX "tfastx34_t"
#define TFASTY "tfasty34_t"
#define TFASTA "tfasta34_t"

#define imin(a,b)       (((a)<(b))?(a):(b))
#define imax(a,b)       (((a)>(b))?(a):(b))

typedef struct gtree_node{
   int id;
   struct gtree_node *ch; /* pointer to the left most child; default: NULL */
   struct gtree_node *sb; /* pointer to the left most sibling; default: NULL */
   struct gtree_node *pr; /* pointer to the parent; root node points to itself */
} GTREE_NODE;

int nexttext(char *a,FILE *in);
int nextline(char *a,FILE *in);
int pack(char *a);
int trimr(char *a);
int triml(char *a);
int isinteger(char *s);
int ispurereal(char *s);
int isexpreal(char *s);
int isanumber(char *s);
int a2i(char *s);
long a2l(char *s);
double a2f(char *s);
void to_fasta(FILE *fp,char *desc,char *seq);
void to_qual(FILE *fp,char *desc,char *qt,int lgh);
int align_to_cigar(char *qsq,char *hsq,char *cigar,char *md);
int csnp(char *seq,int cd_start,int cd_end,int snp_pos,char *allele,char *wild_type_aa,char *changed_aa);
char *nextfasta(FILE *fp,char *desc);
char *nextfasta_nochange(FILE *fp,char *desc);
char *nextqual(FILE *fp,char *desc,long *qt_lgh);
void convqualhex2dec(FILE *fp1,FILE *fp2);
void convquallifeseq2dec(FILE *fp1,FILE *fp2);
int strrcspn(char *s1,char *s2);
int strrspn(char *s1,char *s2);
void strrev(char *s);
char *strrot(char *s,int x);
char *strrstr(char *s1,const char *s2);
char *strcasestr(char *s1,char *s2);
char *strcaserstr(char *s1,char *s2);
char *strtoupper(char *s);
char *strtolower(char *s);
int strreplace(char *a,char *b,char *c);
int strcasereplace(char *a,char *b,char *c);
char **strsplit(char *a,char *b,int *count);
char **strsimplesplit(char *a,char *b,int *count);
void rm_arg(char *args,const char *s);
int aa_wt(int **mtx,char x,char y);
void remove_html(FILE *in,FILE *out);
int get_cgi_s(char *line,char *name,char *val,FILE *log);
int get_cgi_i(char *line,char *name,int *val,FILE *log);
int get_cgi_b(char *line,char *name,int *val,FILE *log);
int get_cgi_f(char *line,char *name,double *val,FILE *log);
int keep_alive(void);
char *strtoken(char *a,const char *b);
char *strsimpletoken(char *a,char *b);
char nt2aa(char *nt);
char *translate(char *seq, int frame);
const char *aa1toaa3(char a);
const char *aa1toaa1(char a);
const char *aa3toaa1(char *a);
const char nttont(char *a);
double aa1tohydrophobicity(char a);
char nt_comp(char c);
char *rev_comp(char *s);
void pt_index(int m,int n);
int longest_common_substring(char *a,char *b,int *a1,int *b1);
double seq_align_user_award(char *sq1,char *sq2,char *al1,char *al2,double *award, int which);
double seq_align_user_penalty(char *sq1,char *sq2,char *al1,char *al2,double *penalty, int which);
int seq_align(char *sq1,char *sq2,char *al1,char *al2);
int seq_align_open(char *sq1,char *sq2,char *al1,char *al2);
int seq_distance(char *sq1,char *sq2);
void permutation_handler_register(int(*f)(int n,int *permutation_array));
void permutation_init (void);
int **combination(int m,int n1,int n2,char w[COMBINATIONMX][COMBINATIONMX],int *n_item);
int generate_combination(int m,int n1,int n2,char w[COMBINATIONMX][COMBINATIONMX],int (*Next_combination)(int *picked,int n_picked));
long comb(int m, int n);
int remove_tail_a(char *mrna);
int remove_poly_t(char *mrna);
int remove_poly_a(char *mrna);
int remove_poly_a2(char *mrna,int a_length,int max_dist);
int read_psipred_ss2(FILE *fp,char *struc, float *C, float *H, float *E);
int read_garnier(FILE *fp,char *struc);
GTREE_NODE *gtree_create(int idx);
void gtree_insert_right_child(GTREE_NODE *p, GTREE_NODE *q);
void gtree_insert_left_child(GTREE_NODE *p, GTREE_NODE *q);
void gtree_insert_right_sibling(GTREE_NODE *p, GTREE_NODE *q);
void gtree_insert_left_sibling(GTREE_NODE *p, GTREE_NODE *q);
GTREE_NODE *gtree_dsf_search(GTREE_NODE *p, int d);
GTREE_NODE *gtree_dsf_next_search(GTREE_NODE *p, int d);
void gtree_dsf_print(GTREE_NODE *p, FILE *out);
void gtree_dsf_action(GTREE_NODE *p, int(*f)(GTREE_NODE *q,int depth));
int rgb(float val,int *r,int *g,int *b,float val_high,float val_low);
int eliminate_singleton(char **a,char **b,int n);
int highlight_keyword(char *a,char *b);
void endian_swap2(unsigned short *x);
void endian_swap4(unsigned int *x);
void endian_swap8(unsigned long long *x);

