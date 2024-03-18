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

module TsnUe2
{
    parameters:
        string nodeType = "UE";  // DO NOT CHANGE
        int masterId @mutable;
        int macNodeId @mutable = default(0); // TODO: this is not a real parameter
        int macCellId @mutable = default(0); // TODO: this is not a real parameter
        int nrMasterId @mutable = default(0);
        int nrMacNodeId @mutable = default(0); // TODO: this is not a real parameter
        int nrMacCellId @mutable = default(0); // TODO: this is not a real parameter
        //# D2D capability
        string nicType = default("NRNicUe");
        string interfaceTableModule;
        *.interfaceTableModule = default(absPath(this.interfaceTableModule));
        *.routingTableModule = default(absPath(".routingTable"));
        
    gates:
        inout phys;
        input nrRadioIn @directIn;
        input radioIn @directIn;
    submodules:
        routingTable: Ipv4RoutingTable {
            parameters:
                @display("p=100,200;is=s");
                routingFile = "Client.mrt";
        }
        interfaceTable: InterfaceTable {
            @display("p=100,318");
        }
        dstt: TSN5GTranslator {
            @display("p=355,291");
        }
        cellularNic: <nicType> like ICellularNic {
            nodeType = parent.nodeType;
            @display("p=355.152,589.50397");
        }
    connections allowunconnected:
        cellularNic.radioIn <-- radioIn;
        cellularNic.nrRadioIn <-- nrRadioIn;
        dstt.phys <--> phys;
        dstt.out --> cellularNic.upperLayerIn;
        dstt.in <-- cellularNic.upperLayerOut;

}
