// 
//                  Simu5G
//
// Authors: Giovanni Nardini, Giovanni Stea, Antonio Virdis (University of Pisa)
// 
// This file is part of a software released under the license included in file
// "license.pdf". Please read LICENSE and README files before using it.
// The above files and the present reference are part of the software itself, 
// and cannot be removed from it.
// 

import inet.applications.contract.IApp;
import inet.common.packet.recorder.PcapRecorder;
import inet.mobility.contract.IMobility;
import inet.linklayer.contract.IEthernetInterface;
import inet.linklayer.contract.ILoopbackInterface;
import inet.linklayer.ethernet.contract.IEthernetLayer;
import inet.networklayer.common.InterfaceTable;
import inet.networklayer.ipv4.*;
import inet.networklayer.contract.IRoutingTable;
import inet.networklayer.contract.INetworkLayer;
import inet.common.packet.recorder.PcapRecorder;
import inet.transportlayer.contract.ITcp;
import inet.transportlayer.contract.IUdp;
import inet.transportlayer.contract.ISctp;
import inet.common.MessageDispatcher;
import simu5g.stack.ICellularNic;
import simu5g.corenetwork.statsCollector.UeStatsCollector;
import inet.transportlayer.udp.Udp;
import simu5g.nodes.NR.NRUe;
import inet.applications.pingapp.PingApp;

module TsnUe extends NRUe
{
    parameters:
		numEthInterfaces = 1;
    gates:
        inout phys;

    submodules:
        dstt: TSN5GTranslator {
            @display("p=575,65");
        }


    connections allowunconnected:
       	dstt.phys <--> phys;
		dstt.out --> at.in++;
		dstt.in <-- at.out++;

}
