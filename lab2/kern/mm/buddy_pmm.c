#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_pmm.h>
#include <stdio.h>
#define BUDDIES_MAXNUM 1024

extern free_area_t free_area;
struct buddy{
    int flag;
    int level;
    size_t level_seq;
    int longest;
};

struct buddy buddies[BUDDIES_MAXNUM];
unsigned int nr_free=BUDDIES_MAXNUM/2;
unsigned int max_level=1;
struct Page* base=NULL;

int pow(int base,int power){
    if(power==0)return 1;
    else return base*power(base,power-1);
}

static void
mark_parent(){
    
}

static void
mark_children(int parent){
    if(2*parent<BUDDIES_MAXNUM){
        buddies[2*parent].longest=0;
        buddies[2*parent+1].longest=0;
        mark_children(2*parent);
        mark_children(2*parent+1);
    }
    else return;
}

static struct Page *
find_page(int pointer,struct Page* empty_pointer){
    if(2*pointer<BUDDIES_MAXNUM){
        return find_page(2*pointer,empty_pointer);
    }
    else return base+buddies[pointer].level_seq
}

static void 
buddy_init(void){
    int current_level=1;
    size_t current_level_seq=1;
    for(int i=1;i<BUDDIES_MAXNUM;i++){//0 is abandoned
        buddies[i].level=current_level;
        buddies[i].level_seq=current_level_seq;
        if(i==pow(2,current_level)-1){
            current_level++;
            current_level_seq=1;
        }
        current_level_seq++;
    }
    max_level=current_level-1
    for(int i=0;i<BUDDIES_MAXNUM;i++){
        buddies[i].longest=pow(2,max_level-buddies[i].level);
    }
    

}

static void 
buddy_memmap_init(struct Page *base, size_t n){
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }


}

static struct Page *
buddy_alloc_pages(size_t n){
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    int satisfy_level=max_level;
    while(pow(2,max_level-satisfy_level)>n){satisfy_level++;}
    satisfy_level--;

    int searching_pointer=pow(2,satisfy_level-1)-1;
    while(buddies[searching_pointer].level>=satisfy_level){
        if(buddies[searching_pointer].longest>=n){
            buddies[searching_pointer].longest-=n;
            mark_children(searching_pointer);
            break;
        }
            
    }

    struct Page* first_page=NULL;
    first_page=find_page(searching_pointer,first_page);
    first_page->property=pow(2,max_level-satisfy_level);
    ClearPageProperty(first_page);
    return first_page;
}

static void
buddy_free_pages(size_t n,struct Page* base){

}