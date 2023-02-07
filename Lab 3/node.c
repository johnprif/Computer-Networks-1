#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "node.h"

int connectcosts[NUMNODES][NUMNODES];
int packets=0;

/* Setup the network costs */
void initcosts() {
	static int initialized = 0;
	if (!initialized) {
		/* initialize by hand since not all compilers allow array initilization */
		connectcosts[0][1] = connectcosts[1][0] = 3; // x0
		connectcosts[1][2] = connectcosts[2][1] = 2; // x1
		connectcosts[2][3] = connectcosts[3][2] = 5; // x2
		connectcosts[0][3] = connectcosts[3][0] = 4; // x3
		connectcosts[1][4] = connectcosts[4][1] = 6; // x4
		connectcosts[0][2] = connectcosts[2][0] = 7; // x5
		connectcosts[3][4] = connectcosts[4][3] = 3; // x6

		/* Not connected nodes */
		connectcosts[0][4] = connectcosts[4][0] = connectcosts[1][3] =
			connectcosts[3][1] = connectcosts[2][4] = connectcosts[4][2] =
			999;

		/* Loopback links */
		connectcosts[0][0] = connectcosts[1][1] = connectcosts[2][2] =
			connectcosts[3][3] = connectcosts[4][4] = 0;
	}
}

/**
 * H synarthsh ayth pairnei san orisma enan deikth se Node. To pedio
 * id ths domhs prepei na einai arxikopoihmeno sto index toy komboy (p.x.
 * 0 gia to node 0, 1 gia to node 1, kok) H synarthsh ayth prepei na
 * arxikopoihsei to routing table toy komboy me bash ton pinaka connectcosts
 * poy orizetai kai arxikopoieitai sto node.c kai katopin na steilei ena
 * katallhlo RtPkt se oloys toys geitonikoys komboys toy node.
 */
void initRT(Node* n) 
{	
	RtPkt packet;
	//RtPkt *packet=(RtPkt *)malloc(sizeof(RtPkt));
	packet.sourceid=n->id;

	for(int i=0; i<NUMNODES; i++)
	{
		n->rt.cost[i]=connectcosts[n->id][i];
		packet.mincost[i]=n->rt.cost[i];
		if(connectcosts[n->id][i] != 999)
		{
			n->rt.nexthop[i]=i;
		}
	}
	for(int i=0; i<NUMNODES; i++)
	{
		packet.destid=i;

		if((n->rt.cost[i] != 999) && (packet.sourceid != packet.destid))
		{
			tolayer2(packet);
			packets++;
		}	
	}	
	//free(packet);
}

/**
 * H synarthsh ayth pairnei san orisma enan deikth se Node kai enan
 * deikth se RtPkt. Prepei na ananewsei to routing table toy Node me
 * bash ta periexomena toy RtPkt kai, an ypar3oyn allages, na steilei ena
 * katallhlo RtPkt se oloys toys geitonikoys komboys toy node.
 */
void updateRT(Node* n, RtPkt* rcvdpkt) 
{
	int flag=0;
	RtPkt updated_packet;
	//RtPkt *updated_packet=(RtPkt *)malloc(sizeof(RtPkt));
	updated_packet.sourceid=n->id;

	for(int i=0; i<NUMNODES; i++)
	{
		if(rcvdpkt->sourceid!=i)
		{
			if((rcvdpkt->mincost[rcvdpkt->destid]+rcvdpkt->mincost[i]) < n->rt.cost[i])
			{
				flag=1;
				n->rt.cost[i]=rcvdpkt->mincost[rcvdpkt->destid]+rcvdpkt->mincost[i];
				n->rt.nexthop[i]=rcvdpkt->sourceid;
			}
		}
		updated_packet.mincost[i]=n->rt.cost[i];
	}

	if(flag==1)
	{
		for(int i=0; i<NUMNODES; i++)
		{
			if((connectcosts[n->id][i]!= 999) && (i != n->id))
			{
				updated_packet.destid=i;
				tolayer2(updated_packet);
				packets++;
			}
		}
	}
	//free(updated_packet);
}

/**
 * H synarthsh ayth pairnei san orisma enan deikth se Node. Prepei na
 * typwsei sto standard output to routing table toy node: apostaseis/costs
 * pros toys alloys komboys kai to epomeno bhma/nexthop gia th dromologhsh
 * paketwn pros aytoys.
 */
void printRT(Node* n) 
{
	for(int i=0; i<NUMNODES; i++)
	{
		printf("node: %d ||destination: %d ||nexthop: %d || cost: %d\n",n->id, i, n->rt.nexthop[i], n->rt.cost[i]);
	}
	if(n->id==4)
	{
		printf("The number of packets is: %d\n", packets);
	}
}

