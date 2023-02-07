#!/bin/sh

LC_NUMERIC=en_US.UTF-8
export LC_NUMERIC

INPUTFILE=lab2.tr

if [ ! -f "$INPUTFILE" ]; then
	echo "ERROR: Can't find input file $INPUTFILE"
	exit 1
elif [ ! -s "$INPUTFILE" ]; then
	echo "ERROR: Empty input file $INPUTFILE"
	exit 1
fi

cat $INPUTFILE | gawk '
	BEGIN{ sign = -1; }
	{
		if ($1=="+") { sign = "0+"; }
		if( $1=="-" ){ sign = "1-"; }
		if ($1=="d") { sign = "2d"; }
		if ($1=="r") { sign = "3r"; }
		printf("%d %f %s %d %d %d\n", 1000 + $12, $2, sign, $3, $4, $6);
	}' | sort | gawk '
	BEGIN{
		generated = serviced = dropped = qcounter1 = qcounter2 = dropped2 = mcount1 = mcount2 = 0; 
		qdelay = mean_delay = final_mdelay = final_qdelay = 0.0;
		prev_packet = prev_qdelay = prev_mdelay = prev_sign = -1;
	}
	{
		if ($3 == "0+" && ($4 == 0 || $4 == 1)) { generated++; }
		if ($3 == "2d" && $4 == 2) { dropped++; }
		if ($3 == "2d" && $4 != 2) { dropped2++; }
		if ($3 == "3r" && $5 == 3) { serviced++; }
		if ($4 == 2 && $3 == "0+") { qcounter1++; }
		if ($4 == 2 && $3 == "1-") { qcounter2++; }

		if (prev_packet != $1) {
			if ($3 == "0+" && ($4 == 0 || $4 == 1)) { prev_mdelay = -$2; }
		}
		
		if (prev_packet == $1) {
			if ($3 == "0+" && $4 == 2) { prev_qdelay = -$2; }
			if ($3 == "2d") { prev_mdelay = prev_qdelay = 0.0; }
			if ($3 == "1-" && $4 ==2 ) {
				if (prev_qdelay != 0) {
					prev_qdelay += $2;
					qdelay += prev_qdelay; 
					mcount2++;
				}
				prev_qdelay = 0.0;
			}
			if ($3 == "3r" && $5 == 3) {
				if (prev_mdelay != 0) {
					prev_mdelay += $2;
					mean_delay += prev_mdelay; 
					mcount1++;
				};
				prev_mdelay = 0.0; 
			}
		}
		prev_packet = $1;
	}
	END{
		print "Generated Packets			:",generated;
		print "Serviced Packets			:", serviced;
		print "Dropped	in queue 2-3			:",dropped;
		print "Dropped	in other queues			:",dropped2;
#		print "In queue	of node 2		:", qcounter1-qcounter2-dropped;
		print "Delivery Ratio (%)			:", 100*serviced/(serviced+dropped+dropped2);

		if (mcount1 != 0) { final_mdelay = mean_delay / mcount1; } else { final_mdelay = 0.0; }
		if (mcount2 != 0) { final_qdelay = qdelay / mcount2; } else { final_qdelay = 0.0; }
		print "Mean packet delay (secs)		:", final_mdelay;
		print "Mean queueing delay in queue 2-3 (secs)	:", final_qdelay;
	}'

cat $INPUTFILE | awk '

	BEGIN {

	fromNode=2; toNode=3;

	lineCount = 0;totalBits = 0;

	}

	{

		if($3 == fromNode && $4 == toNode)
       		{
			if($1 == "-")
			{
				totalBits += 8*$6;
				if ( lineCount == 0) 
				{
	
					timeBegin = $2;
					lineCount++;

				}
			} 
			else 
			{
				timeEnd = $2;
			}
		}

	}

	END{
		#printf("Start time:%f, End time:%f\n",timeBegin,timeEnd);
		duration = timeEnd-timeBegin;

		printf("Link: %d-%d\n",fromNode,toNode); 
		printf("---------\n");		
		#printf("Total transmitted bits = %d\n",totalBits); 
		#printf("Duration = %f sec\n",duration); 
		printf("Throughput = %f Kbps\n",totalBits/duration/1e3);
		printf("Link utilization = Thoughput / Link Capacity\n");
	}'


