function status = scanboxUDP(message)

    %scanboxUDP() Apparently MATLAB doesn't freaking want to listen to my freaking UDP message from Python so we've got to get real freaking stupid about this.

    udp_sender = udp('127.0.0.1', 'RemotePort', 7000);

    fopen(udp_sender);

    fprintf(udp_sender, message);
    
    status = 'success';
    
end