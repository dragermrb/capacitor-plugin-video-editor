import Foundation;

enum TrimSettingsError: Error {
    case invalidArgument(message: String)
}

public class TrimSettings: NSObject
{
    private var startsAt: Int = 0;
    private var endsAt: Int = 0;
    
    init(startsAt: Int, endsAt: Int) throws
    {
        if (startsAt < 0)
        {
            throw TrimSettingsError.invalidArgument(message: "Parameter startsAt cannot be negative");
        }
        if (endsAt < 0)
        {
            throw TrimSettingsError.invalidArgument(message: "Parameter endsAt cannot be negative");
        }
        self.startsAt = startsAt;
        self.endsAt = endsAt;
    }
    
    func getStartsAt()->Int
    {
        return self.startsAt;
    }
    
    func setStartsAt(_ startsAt: Int) throws
    {
        if (startsAt < 0)
        {
            throw TrimSettingsError.invalidArgument(message: "Parameter startsAt cannot be negative");
        }
        self.startsAt = startsAt;
    }
    
    func getEndsAt()->Int
    {
        return self.endsAt;
    }
    
    func setEndsAt(_ endsAt: Int) throws
    {
        if (endsAt < 0)
        {
            throw TrimSettingsError.invalidArgument(message: "Parameter endsAt cannot be negative");
        }
        self.endsAt = endsAt;
    }
}
