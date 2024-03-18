//package tsn5g.simulations;
import xmlTranslator.XmlReader;
import inet.networklayer.configurator.ipv4.Ipv4NetworkConfigurator;
import inet.networklayer.ipv4.RoutingTableRecorder;
import simu5g.common.binder.Binder;
import simu5g.world.radio.LteChannelControl;
import simu5g.common.carrierAggregation.CarrierAggregation;
import simu5g.nodes.Upf;
import simu5g.nodes.NR.gNodeB;
import simu5g.nodes.NR.NRUe;
import inet.node.tsn.*;

import inet.node.ethernet.Eth10M;
import inet.node.inet.Router;
import inet.node.inet.StandardHost;
import inet.networks.base.TsnNetworkBase;

network TSN5G extends TsnNetworkBase
{
    parameters:
        *.eth[*].bitrate = default(10Mbps);
        @display("bgb=1747.6351,932.99255");
    submodules:
        carrierAggregation: CarrierAggregation {
            @display("p=1479.2579,399.09598");
        }
        channelControl: LteChannelControl {
            @display("p=1477.812,52.056;is=s");
        }
        routingRecorder: RoutingTableRecorder {
            @display("p=1479.2579,187.98;is=s");
        }
        binder: Binder {
            @display("p=1479.2579,294.98398;is=s");
        }
        tsnServer: MyTsnDevice {
            @display("p=1132.2999,209.56");
        }
        //        tsnClock: TsnClock {
        //
        //            @display("p=733.122,108.45");
        //        }
        tsnSwitch: TsnSwitch {
            @display("p=985.26996,334.62");
        }
        upf: Upf {
            @display("p=682.76,251.81");
        }
        gnb: gNodeB {
            @display("p=772.32996,398.84;is=vl");
        }
        tsnClient1: MyTsnDevice {
            @display("p=415,550");
        }
        //        tsnDevice2: MyTsnDevice {
        //            @display("p=1079.9099,902.45996");
        //        }
        //        tsnDevice3: MyTsnDevice {
        //            @display("p=339.69,709.8");
        //        }
        ue1: TsnUe {
            @display("p=415,312");
        }
        //        ue2: TsnUe {
        //            @display("p=1252.2899,772.32996");
        //        }
        //        ue3: TsnUe {
        //            @display("p=478.27,694.58997");
        //        }
        nwtt: NWTT {
            tt.destAddress = "tsnDevice";
            @display("p=861.89996,199.42");
        }
        xmlReader: XmlReader;
            
    connections:
        tsnClient1.ethg++ <--> Eth10M <--> ue1.phys;
        //        tsnDevice2.ethg++ <--> Eth10M <--> ue2.phys;
        //        tsnDevice3.ethg++ <--> Eth10M <--> ue3.phys;
        tsnSwitch.ethg++ <--> Eth10M <--> tsnServer.ethg++;
        nwtt.pppg <--> Eth10M <--> upf.filterGate;
        nwtt.phys <--> tsnSwitch.ethg++;
        upf.pppg++ <--> Eth10M <--> gnb.ppp;
}
