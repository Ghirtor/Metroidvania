#include <sys/types.h>   /* for type definitions */
#include <sys/socket.h>  /* for socket API function calls */
#include <netinet/in.h>  /* for address structs */
#include <arpa/inet.h>   /* for sockaddr_in */
#include <stdio.h>       /* for printf() */
#include <stdlib.h>      /* for atoi() */
#include <string.h>      /* for strlen() */
#include <unistd.h>      /* for close() */
#include <sys/time.h>    /* for clock */
#include <fcntl.h>       /* to set non blocking socket */

#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>

#include <pthread.h>

#define MAX_LEN  1024    /* maximum string size to send */
#define MIN_PORT 1024    /* minimum port allowed */
#define MAX_PORT 65535   /* maximum port allowed */
#define CO_TIMEOUT 5000  /* timeout of connection */

//#define DEBUG

const unsigned char TYPE_LAUNCH = 0;
const unsigned char TYPE_PLAY = 1;
const unsigned char TYPE_CLOSE = 2;

const unsigned char STATE_STOP = 0;
const unsigned char STATE_RUN = 1;
const unsigned char STATE_JUMP = 2;

int status;

#pragma pack(1)
struct packetData {
    long player_id;
    long ennemy_id;
    unsigned char type;
    unsigned char level;
    int positionX;
    int positionY;
    int direction;
    unsigned char life;
    signed char frame;
    unsigned char state;
    long time;
    unsigned char display;
    unsigned char fire;
};
#pragma pack(0)

double id_player;
double id_ennemy;
long last_time_checkpoint;

/* sender */
int sock;                   /* socket descriptor */
char send_str[MAX_LEN];     /* string to send */
struct sockaddr_in mc_addr; /* socket address structure */
unsigned int send_len;      /* length of string to send */
char* mc_addr_str;          /* multicast IP address */
unsigned short mc_port;     /* multicast port */
unsigned char mc_ttl = 255; /* time to live (hop count) */

/* receiver */
int sock2;                    /* socket descriptor */
int flag_on = 1;              /* socket option flag */
struct sockaddr_in mc_addr2;  /* socket address structure */
char recv_str[MAX_LEN+1];     /* buffer to receive string */
int recv_len;                 /* length of string received */
struct ip_mreq mc_req;        /* multicast request structure */
char* mc_addr_str2;           /* multicast IP address */
unsigned short mc_port2;      /* multicast port */
struct sockaddr_in from_addr; /* packet source */
unsigned int from_len;        /* source addr length */

const int SENDRATE = 16;

struct packetData *player;
struct packetData *ennemy;
struct packetData *tmp;

int connection;
pthread_mutex_t mutex_connection;
pthread_mutex_t mutex_player;
pthread_mutex_t mutex_ennemy;
pthread_mutex_t mutex_status;

long current_timestamp() {
    struct timeval te;
    gettimeofday(&te, NULL); // get current time
    long long milliseconds = te.tv_sec*1000LL + te.tv_usec / 1000; // calculate milliseconds
    return milliseconds;
}

/* close connection */
CAMLprim
value caml_close_connection(value unit) {
    CAMLparam1(unit);
    pthread_mutex_lock(&mutex_connection);
    connection = 0;
    pthread_mutex_unlock(&mutex_connection);
    CAMLreturn(Val_unit);
}

/* get connection state */
CAMLprim
value caml_get_connection(value unit) {
    pthread_mutex_lock(&mutex_connection);
    int i;
    i = connection;
    pthread_mutex_unlock(&mutex_connection);
    return Val_int(i);
}

/* get status */
CAMLprim
value caml_get_status(value unit) {
    pthread_mutex_lock(&mutex_status);
    int i;
    i = status;
    pthread_mutex_unlock(&mutex_status);
    return Val_int(i);
}

/* get fire */
CAMLprim
value caml_get_fire(value unit) {
    pthread_mutex_lock(&mutex_ennemy);
    int i;
    i = ennemy->fire;
    pthread_mutex_unlock(&mutex_ennemy);
    return Val_int(i);
}

/* get life */
CAMLprim
value caml_get_life(value unit) {
    pthread_mutex_lock(&mutex_ennemy);
    int i;
    i = ennemy->life;
    pthread_mutex_unlock(&mutex_ennemy);
    return Val_int(i);
}

/* get display */
CAMLprim
value caml_get_display(value unit) {
    pthread_mutex_lock(&mutex_ennemy);
    int i;
    i = ennemy->display;
    pthread_mutex_unlock(&mutex_ennemy);
    return Val_int(i);
}

/* send ennemy datas to ocaml program */
CAMLprim
value caml_send_datas(value unit) {
    CAMLparam0();
    CAMLlocal1(datas);
    datas = caml_alloc(6, 0);
    pthread_mutex_lock(&mutex_ennemy);
    Store_field(datas, 0, Val_int(ennemy->positionX));
    Store_field(datas, 1, Val_int(ennemy->positionY));
    Store_field(datas, 2, Val_int(ennemy->frame));
    Store_field(datas, 3, Val_int(ennemy->state));
    Store_field(datas, 4, Val_int(ennemy->direction));
    Store_field(datas, 5, Val_int(current_timestamp() - ennemy->time));
    pthread_mutex_unlock(&mutex_ennemy);
    CAMLreturn(datas);
}

/* set player datas to send it to ennemy */
CAMLprim
value caml_set_player_datas(value x, value y, value f, value s, value d) {
    pthread_mutex_lock(&mutex_player);
    CAMLparam4(x, y, f, s);
    player->positionX = Int_val(x);
    player->positionY = Int_val(y);
    player->direction = Int_val(d);
    player->frame = Int_val(f);
    player->state = Int_val(s);
    pthread_mutex_unlock(&mutex_player);
    CAMLreturn(Val_unit);
}

/* set level of player */
CAMLprim
value caml_set_player_level(value l) {
    pthread_mutex_lock(&mutex_player);
    CAMLparam1(l);
    player->level = Int_val(l);
    pthread_mutex_unlock(&mutex_player);
    CAMLreturn(Val_unit);
}

/* set fire of player */
CAMLprim
value caml_set_player_fire(value l) {
    pthread_mutex_lock(&mutex_player);
    CAMLparam1(l);
    player->fire = Int_val(l);
    pthread_mutex_unlock(&mutex_player);
    CAMLreturn(Val_unit);
}

/* set life of player */
CAMLprim
value caml_set_player_life(value l) {
    pthread_mutex_lock(&mutex_player);
    CAMLparam1(l);
    player->life = Int_val(l);
    pthread_mutex_unlock(&mutex_player);
    CAMLreturn(Val_unit);
}

/* set display of player */
CAMLprim
value caml_set_player_display(value l) {
    pthread_mutex_lock(&mutex_player);
    CAMLparam1(l);
    player->display = Int_val(l);
    pthread_mutex_unlock(&mutex_player);
    CAMLreturn(Val_unit);
}

CAMLprim
value caml_init(value ip, value port) {
    pthread_mutex_init(&mutex_player, NULL);
    pthread_mutex_init(&mutex_ennemy, NULL);
    pthread_mutex_init(&mutex_connection, NULL);
    pthread_mutex_init(&mutex_status, NULL);
    pthread_mutex_lock(&mutex_status);
    status = 0;
    pthread_mutex_unlock(&mutex_status);
    last_time_checkpoint = current_timestamp();
    pthread_mutex_lock(&mutex_connection);
    connection = 1;
    pthread_mutex_unlock(&mutex_connection);
    player = malloc(sizeof(struct packetData));
    ennemy = malloc(sizeof(struct packetData));
    tmp = malloc(sizeof(struct packetData));
    CAMLparam2(ip, port);
    id_player = current_timestamp();
    id_ennemy = -1;
    player->player_id = id_player;
    player->ennemy_id = -1;
    ennemy->time = current_timestamp();
    mc_addr_str = String_val(ip);
    mc_port = atoi(String_val(port));
    mc_addr_str2 = String_val(ip);
    mc_port2 = atoi(String_val(port));
    /* validate the port range */
    #if defined(DEBUG)
        if ((mc_port < MIN_PORT) || (mc_port > MAX_PORT)) {
            fprintf(stderr, "Invalid port number argument %d.\n", mc_port);
            fprintf(stderr, "Valid range is between %d and %d.\n", MIN_PORT, MAX_PORT);
            exit(1);
        }
        if ((mc_port2 < MIN_PORT) || (mc_port2 > MAX_PORT)) {
            fprintf(stderr, "Invalid port number argument %d.\n", mc_port2);
            fprintf(stderr, "Valid range is between %d and %d.\n", MIN_PORT, MAX_PORT);
            exit(1);
        }
    #endif
    /* create a socket for sending to the multicast address */
    if ((sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0) {
        #if defined(DEBUG)
            perror("socket() failed");
            exit(1);
        #endif
    }
    /* set the TTL (time to live/hop count) for the send */
    if ((setsockopt(sock, IPPROTO_IP, IP_MULTICAST_TTL, (void*) &mc_ttl, sizeof(mc_ttl))) < 0) {
        #if defined(DEBUG)
            perror("setsockopt() failed");
            exit(1);
        #endif
    }
    /* construct a multicast address structure */
    memset(&mc_addr, 0, sizeof(mc_addr));
    mc_addr.sin_family      = AF_INET;
    mc_addr.sin_addr.s_addr = inet_addr(mc_addr_str);
    mc_addr.sin_port        = htons(mc_port);
    /* clear send buffer */
    memset(send_str, 0, sizeof(send_str));

    /* create socket to join multicast group on */
    if ((sock2 = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0) {
        #if defined(DEBUG)
            perror("socket() failed");
            exit(1);
        #endif
    }

    /* set reuse port to on to allow multiple binds per host */
    if ((setsockopt(sock2, SOL_SOCKET, SO_REUSEADDR, &flag_on, sizeof(flag_on))) < 0) {
        #if defined(DEBUG)
            perror("setsockopt() failed");
            exit(1);
        #endif
    }

    /* construct a multicast address structure */
    memset(&mc_addr2, 0, sizeof(mc_addr2));
    mc_addr2.sin_family      = AF_INET;
    mc_addr2.sin_addr.s_addr = htonl(INADDR_ANY);
    mc_addr2.sin_port        = htons(mc_port2);

    /* bind to multicast address to socket */
    if ((bind(sock2, (struct sockaddr *) &mc_addr2, sizeof(mc_addr2))) < 0) {
        #if defined(DEBUG)
            perror("bind() failed");
            exit(1);
        #endif
    }

    /*int nonBlocking = 1;
    if (fcntl(sock2, F_SETFL, O_NONBLOCK, nonBlocking) == -1) {
        perror("failed to set non-blocking socket");
        exit(1);
    }*/

    /* construct an IGMP join request structure */
    mc_req.imr_multiaddr.s_addr = inet_addr(mc_addr_str2);
    mc_req.imr_interface.s_addr = htonl(INADDR_ANY);

    /* send an ADD MEMBERSHIP message via setsockopt */
    if ((setsockopt(sock2, IPPROTO_IP, IP_ADD_MEMBERSHIP, (void*) &mc_req, sizeof(mc_req))) < 0) {
        #if defined(DEBUG)
            perror("setsockopt() failed");
            exit(1);
        #endif
    }

    CAMLreturn(Val_unit);
}

pthread_t thread1;
pthread_t thread2;

/* free memory and close sockets */
CAMLprim
value caml_close(value unit) {
    pthread_cancel (thread2);
    pthread_cancel (thread1);
    pthread_join(thread2, NULL);
    pthread_join(thread1, NULL);
    CAMLparam1(unit);
    close(sock);
    close(sock2);
    pthread_mutex_destroy(&mutex_player);
    pthread_mutex_destroy(&mutex_ennemy);
    pthread_mutex_destroy(&mutex_connection);
    pthread_mutex_destroy(&mutex_status);
    free(player);
    free(ennemy);
    free(tmp);
    CAMLreturn(Val_unit);
}

void *thread_1(void *arg) {
    int matchmaking = 1;
    int playing = 1;
    pthread_mutex_lock(&mutex_player);
    player->type = TYPE_LAUNCH;
    player->player_id = id_player;
    pthread_mutex_unlock(&mutex_player);
    long t;
    struct timespec ti;
    ti.tv_nsec = (SENDRATE % 1000) * 1000000;
    ti.tv_sec = SENDRATE / 1000;
    pthread_mutex_lock(&mutex_status);
    status = 0;
    pthread_mutex_unlock(&mutex_status);
    while (matchmaking) {
        t = current_timestamp();
        #if defined(DEBUG)
            printf("matchmaking\n");
        #endif
        pthread_mutex_lock(&mutex_connection);
        if (connection == 0)
            matchmaking = 0;
        pthread_mutex_unlock(&mutex_connection);
        pthread_mutex_lock(&mutex_player);
        if (player->player_id != -1 && player->ennemy_id != -1)
            matchmaking = 0;
        if ((sendto(sock, player, sizeof(*player), 0, (struct sockaddr *) &mc_addr, sizeof(mc_addr))) != sizeof(*player)) {
            #if defined(DEBUG)
                perror("sendto() sent incorrect number of bytes");
                exit(1);
            #endif
        }
        pthread_mutex_unlock(&mutex_player);
        nanosleep(&ti, &ti);
        #if defined(DEBUG)
            printf("%ld %ld %ld\n", (current_timestamp() - t), t, current_timestamp());
        #endif
    }
    pthread_mutex_lock(&mutex_player);
    player->type = TYPE_PLAY;
    pthread_mutex_unlock(&mutex_player);

    pthread_mutex_lock(&mutex_status);
    status = 1;
    pthread_mutex_unlock(&mutex_status);
    while (playing) {
        /* send player struct to multicast address */
        pthread_mutex_lock(&mutex_player);
        player->time = current_timestamp();
        if ((sendto(sock, player, sizeof(*player), 0, (struct sockaddr *) &mc_addr, sizeof(mc_addr))) != sizeof(*player)) {
            playing = 0;
            #if defined(DEBUG)
                perror("sendto() sent incorrect number of bytes");
                exit(1);
            #endif
        }
        player->fire = 0;
        pthread_mutex_unlock(&mutex_player);
        nanosleep(&ti, &ti);
        pthread_mutex_lock(&mutex_connection);
        if (current_timestamp() - last_time_checkpoint > CO_TIMEOUT) {
            #if defined(DEBUG)
                printf("timeout with ennemy connexion\n");
            #endif
            connection = 0;
        }
        if (connection == 0) {
            playing = 0;
            pthread_mutex_lock(&mutex_player);
            player->type = TYPE_CLOSE;
            pthread_mutex_lock(&mutex_status);
            status = 2;
            pthread_mutex_unlock(&mutex_status);
            if ((sendto(sock, player, sizeof(*player), 0, (struct sockaddr *) &mc_addr, sizeof(mc_addr))) != sizeof(*player)) {
                #if defined(DEBUG)
                    perror("sendto() sent incorrect number of bytes");
                    exit(1);
                #endif
            }
            //pthread_cancel (thread2);
            pthread_mutex_unlock(&mutex_player);
        }
        pthread_mutex_unlock(&mutex_connection);
    }
    /* to remove warning */
    (void) arg;
    pthread_exit(NULL);
}

void *thread_2(void *arg) {
    int matchmaking = 1;
    int playing = 1;
    pthread_mutex_lock(&mutex_player);
    player->type = TYPE_LAUNCH;
    player->player_id = id_player;
    pthread_mutex_unlock(&mutex_player);
    while (matchmaking) {
        pthread_mutex_lock(&mutex_connection);
        if (connection == 0)
            matchmaking = 0;
        pthread_mutex_unlock(&mutex_connection);
        pthread_mutex_lock(&mutex_ennemy);
        pthread_mutex_unlock(&mutex_ennemy);
        if ((recv_len = recvfrom(sock2, tmp, MAX_LEN, 0, (struct sockaddr*)&from_addr, &from_len)) > 0) {
            /* output received string */
            #if defined(DEBUG)
                printf("Received %d bytes from %s: ", recv_len, inet_ntoa(from_addr.sin_addr));
                printf("%d %ld %ld\n", tmp->type, tmp->player_id, tmp->ennemy_id);
            #endif
            pthread_mutex_lock(&mutex_player);
            if (tmp->type == TYPE_LAUNCH && tmp->player_id != id_player && tmp->level == player->level) {
                player->ennemy_id = tmp->player_id;
                matchmaking = 0;
            }
            pthread_mutex_unlock(&mutex_player);
        }
    }
    /*pthread_mutex_lock(&mutex_player);
    player->type = TYPE_PLAY;
    pthread_mutex_unlock(&mutex_player);*/
    //fd_set ReadFDs;
    while (playing) {
        //FD_ZERO(&ReadFDs);
        //FD_SET(sock2, &ReadFDs);
        /* clear the receive buffers & structs */
        from_len = sizeof(from_addr);
        memset(&from_addr, 0, from_len);
        //if (select(sock2 + 1, &ReadFDs, NULL, NULL, NULL) > 0) {
                //if (FD_ISSET(sock2, &ReadFDs)) {
        /* block waiting to receive a packet */
        if ((recv_len = recvfrom(sock2, tmp, MAX_LEN, 0, (struct sockaddr*)&from_addr, &from_len)) > 0) {
            pthread_mutex_lock(&mutex_connection);
            pthread_mutex_lock(&mutex_player);
            if (player->ennemy_id == tmp->player_id && player->player_id == tmp->ennemy_id && connection) {
                if (tmp->type == TYPE_PLAY || tmp->type == TYPE_CLOSE) {
                    last_time_checkpoint = current_timestamp();
                    pthread_mutex_lock(&mutex_ennemy);
                    if (tmp->time > ennemy->time) {
                        ennemy->type = tmp->type;
                        ennemy->positionX = tmp->positionX;
                        ennemy->positionY = tmp->positionY;
                        ennemy->direction = tmp->direction;
                        ennemy->frame = tmp->frame;
                        ennemy->state = tmp->state;
                        ennemy->time = tmp->time;
                        ennemy->life = tmp->life;
                        ennemy->display = tmp->display;
                        ennemy->fire = tmp->fire;
                    }
                    pthread_mutex_unlock(&mutex_ennemy);
                }
                else if (tmp->type == TYPE_CLOSE) {
                    #if defined(DEBUG)
                        printf("ennemy : %ld interrupted connexion", tmp->ennemy_id);
                    #endif
                    pthread_mutex_lock(&mutex_player);
                    player->type = TYPE_CLOSE;
                    pthread_mutex_unlock(&mutex_player);
                    pthread_mutex_lock(&mutex_connection);
                    connection = 0;
                    pthread_mutex_unlock(&mutex_connection);
                }
            }
            pthread_mutex_unlock(&mutex_player);
            pthread_mutex_unlock(&mutex_connection);
            /* output received string */
            #if defined(DEBUG)
                printf("Received %d bytes from %s: ", recv_len, inet_ntoa(from_addr.sin_addr));
                printf(" id = %ld opp_id = %ld datas = %d, %d, %d, %d, %d, latency = %ld ms\n", tmp->player_id, tmp->ennemy_id, tmp->type, tmp->positionX, tmp->positionY, tmp->frame, tmp->state, (current_timestamp() - tmp->time));
            #endif
        //}
                //}
        }
        pthread_mutex_lock(&mutex_connection);
        if (connection == 0)
            playing = 0;
        pthread_mutex_unlock(&mutex_connection);
    }
    /* to remove warning */
    (void) arg;
    pthread_exit(NULL);
}

CAMLprim
value caml_send(value unit) {
    CAMLparam1(unit);
    if (pthread_create(&thread2, NULL, thread_2, NULL)) {
        #if defined(DEBUG)
            perror("error while creating thread");
            return EXIT_FAILURE;
        #endif
    }
    if (pthread_create(&thread1, NULL, thread_1, NULL)) {
        #if defined(DEBUG)
            perror("error while creating thread");
            return EXIT_FAILURE;
        #endif
    }
    CAMLreturn(Val_unit);
}
