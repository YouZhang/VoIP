% CLIENT connect to a server and read a message
%
% Usage - message = client(host, port, number_of_retries)
function message = client(host, port, number_of_retries)

%     import java.net.Socket
    import java.io.*
    import java.net.*
    if (nargin < 3)
        number_of_retries = 20; % set to -1 for infinite
    end
    
    retry        = 0;
    input_socket = [];
    message      = [];
    bytes_available = 0;
    addr = InetSocketAddress(host,port);
    Timeout = 4300;
%     InetAddress addr;
%     addr = InetAddress.getByName('host');
%     Socket socket;
%     socket = Socket();
%     socket.soTimeout = 3000;
    
%     socket.
%     try
%       socket.connect(host, port, 5000 );
%       socket.setSendBufferSize(9000);
%     catch
%       if ~isempty(input_socket)
%            input_socket.close;
%       end 
%     end
%       BufferedWriter out = new BufferedWriter( new OutputStreamWriter( socket.getOutputStream() ) );
    while true

        retry = retry + 1;
        if ((number_of_retries > 0) && (retry > number_of_retries))
            fprintf(1, 'Too many retries\n');
            break;
        end
        
        try
            fprintf(1, 'Retry %d connecting to %s:%d\n', ...
                    retry, host, port);

            % throws if unable to connect
%             input_socket = Socket(host,port);
%             input_stream   = input_socket.getInputStream;
%             d_input_stream = DataInputStream(input_stream);
% 
%             fprintf(1, 'Connected to server\n');

%             pause(0.8);
%             bytes_available = input_stream.available;
            while(~bytes_available)
%                 addr = [host,port];
%                 input_socket = Socket(host,port);
                input_socket = Socket();
                input_socket.connect(addr,Timeout);
                input_stream   = input_socket.getInputStream;
                d_input_stream = DataInputStream(input_stream);
                fprintf(1, 'Connected to server\n');
                pause(0.5);
                bytes_available = input_stream.available;
            end
%                 pause(0.8);
%                 bytes_available = input_stream.available;
            fprintf(1, 'Reading %d bytes\n', bytes_available);

            message = zeros(1, bytes_available, 'uint8');
            for i = 1:bytes_available
                %
                message(i) = d_input_stream.readByte;
            end

            message = char(message);

            % cleanup
            input_socket.close;
            break;
            
            
        catch
            if ~isempty(input_socket)
                input_socket.close;
            end

            % pause before retrying
            pause(0.5);
        end
    end
end