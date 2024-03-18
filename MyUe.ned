//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.
//
import inet.common.packet.recorder.PcapRecorder;
import inet.mobility.contract.IMobility;
import inet.linklayer.contract.IEthernetInterface;
import inet.linklayer.contract.ILoopbackInterface;
import inet.linklayer.ethernet.contract.IEthernetLayer;
import inet.networklayer.common.InterfaceTable;
import inet.networklayer.ipv4.Ipv4RoutingTable;
import inet.networklayer.ipv4.RoutingTableRecorder;
import inet.networklayer.contract.IRoutingTable;
import inet.networklayer.contract.INetworkLayer;
import inet.common.packet.recorder.PcapRecorder;
import inet.common.MessageDispatcher;
import simu5g.stack.ICellularNic;

import simu5g.corenetwork.statsCollector.UeStatsCollector;

module MyUe
{
    parameters:
        int numEthinterfaces = default(1);
        @networkNode();
        @display("i=device/pocketpc;bgb=716,578");
        @figure[networkLayer](type=rectangle; pos=250,306; size=600,130; fillColor=#00ff00; lineColor=#808080; cornerRadius=5; fillOpacity=0.1);
        @figure[networkLayer.title](type=text; pos=845,311; anchor=ne; text="network layer");
        @figure[linkLayer](type=rectangle; pos=250,456; size=600,130; fillColor=#0000ff; lineColor=#808080; cornerRadius=5; fillOpacity=0.1);
        @figure[linkLayer.title](type=text; pos=845,461; anchor=ne; text="link layer");
        @figure[submodules];

		//# Mobility
        mobility.typename = default("StationaryMobility");
        string nodeType = "UE";
        int nrMasterId @mutable = default(0);
        int nrMacNodeId @mutable = default(0);
        int nrMacCellId @mutable = default(0);
        int masterId @mutable;
        int macNodeId @mutable = default(0); // TODO: this is not a real parameter
        int macCellId @mutable = default(0); // TODO: this is not a real parameter

        string nicType = default("NRNicUe");

        bool hasIpv4 = default(true);
        bool hasIpv6 = default(false);
        *.interfaceTableModule = default(absPath(".interfaceTable"));
        *.routingTableModule = default("^.ipv4.routingTable");
        int numEthInterfaces = default(1);
        string extHostAddress = default("");

        //# Loopback interfaces
        int numLoInterfaces = default(1);

        //# Num of PcapRecorders
        int numPcapRecorders = default(0); // no of PcapRecorders

        bool hasRNISupport = default(false);

    gates:
        input nrRadioIn @directIn;
        inout phys;

    submodules:
        cellularNic: <nicType> like ICellularNic {
            nodeType = parent.nodeType;
            @display("p=322,495");
        }

        //# ethernet interface used for communicating with external applications in emulation mode
        eth[numEthInterfaces]: <default("EthernetInterface")> like IEthernetInterface {
            parameters:
                @display("p=629,495,row,150;q=txQueue");
        }
        encap: <default("EthernetEncapsulation")> like IEthernetLayer if typename != "" {
            parameters:
                registerProtocol = true;
                @display("p=629,402");
        }
        //# network layer
        ipv4: <default("Ipv4NetworkLayer")> like INetworkLayer if hasIpv4 {
            parameters:
                @display("p=470,246;q=queue");
        }
        //# link layer 
        lo[numLoInterfaces]: <default("LoopbackInterface")> like ILoopbackInterface {
            parameters:
                @display("p=470,495,row,150");
        }
        //# message dispatcher for SAP to link layer
        nl: MessageDispatcher {
            parameters:
                @display("p=470,339;b=488,10,,,,1");
        }
        interfaceTable: InterfaceTable {
            @display("p=126,209;is=s");
        }
        mobility: <default("")> like IMobility if typename != "" {
            @display("p=126,124;is=s");
        }

        //# layer submodules (must be ordered from lower to upper layers)

        //# PcapRecorders
        pcapRecorder[numPcapRecorders]: PcapRecorder {
            @display("p=126.84,346.69598,r,10");
        }

        //# UeStatsCollector - for MEC
        ueCollector: UeStatsCollector if hasRNISupport {
            @display("p=127,534;is=s");
        }
        //# message dispatcher for SAP to link layer
        tn: MessageDispatcher {
            parameters:
                @display("p=470,157;b=488,10,,,,1");
        }
    connections allowunconnected:
        eth[0].phys <--> phys;
        encap.upperLayerOut --> nl.in++ if numEthInterfaces != 0;
        encap.upperLayerIn <-- nl.out++ if numEthInterfaces != 0;
        encap.lowerLayerOut --> eth[0].upperLayerIn;
        encap.lowerLayerIn <-- eth[0].upperLayerOut;
        cellularNic.nrRadioIn <-- nrRadioIn;

        ipv4.ifOut --> nl.in++ if hasIpv4;
        ipv4.ifIn <-- nl.out++ if hasIpv4;
        ipv4.transportIn <-- tn.out++ if hasIpv4;
        ipv4.transportOut --> tn.in++ if hasIpv4;

        cellularNic.upperLayerOut --> nl.in++;
        cellularNic.upperLayerIn <-- nl.out++;

        nl.out++ --> lo[0].upperLayerIn;
        lo[0].upperLayerOut --> nl.in++;

}
