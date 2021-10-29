import Foundation;

enum TrimSettingsError: Error {
    case invalidArgument(message: String)
}

public class TrimSettings: NSObject
{
    private var startsAt: Double = 0;
    private var endsAt: Double = 0;
    
    init(startsAt: Double, endsAt: Double) throws
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
    
    func getStartsAt()->Double
    {
        return self.startsAt;
    }
    
    func setStartsAt(_ startsAt: Double) throws
    {
        if (startsAt < 0)
        {
            throw TrimSettingsError.invalidArgument(message: "Parameter startsAt cannot be negative");
        }
        self.startsAt = startsAt;
    }
    
    func getEndsAt()->Double
    {
        return self.endsAt;
    }
    
    func setEndsAt(_ endsAt: Double) throws
    {
        if (endsAt < 0)
        {
            throw TrimSettingsError.invalidArgument(message: "Parameter endsAt cannot be negative");
        }
        self.endsAt = endsAt;
    }
}
