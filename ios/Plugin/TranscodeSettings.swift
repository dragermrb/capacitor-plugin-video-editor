import Foundation;

enum TranscodeSettingsError: Error {
    case invalidArgument(message: String)
}

public class TranscodeSettings: NSObject
{
    private var height: Int = 0;
    private var width: Int = 0;
    private var keepAspectRatio: Bool = true;
    private var codec: String = "";
    
    init(height: Int, width: Int, keepAspectRatio: Bool, codec: String) throws
    {
        if (height < 0)
        {
            throw TranscodeSettingsError.invalidArgument(message: "Parameter height cannot be negative");
        }
        if (width < 0)
        {
            throw TranscodeSettingsError.invalidArgument(message: "Parameter width cannot be negative");
        }
        self.height = height;
        self.width = width;
        self.keepAspectRatio = keepAspectRatio;
        self.codec = codec;
    }
    
    func getHeight()->Int
    {
        return self.height;
    }
    
    func setHeight(_ height: Int) throws
    {
        if (height < 0)
        {
            throw TranscodeSettingsError.invalidArgument(message: "Parameter height cannot be negative");
        }
        self.height = height;
    }
    
    func getWidth()->Int
    {
        return self.width;
    }
    
    func setWidth(_ width: Int) throws
    {
        if (width < 0)
        {
            throw TranscodeSettingsError.invalidArgument(message: "Parameter width cannot be negative");
        }
        self.width = width;
    }
    
    func isKeepAspectRatio()->Bool
    {
        return self.keepAspectRatio;
    }
    
    func setKeepAspectRatio(_ keepAspectRatio: Bool)
    {
        self.keepAspectRatio = keepAspectRatio;
    }
    
    func getCodec()->String?
    {
        return self.codec;
    }
    
    func setCodec(_ codec: String)
    {
        self.codec = codec;
    }
}
