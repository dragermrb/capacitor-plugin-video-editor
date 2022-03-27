import Foundation;

enum TrimSettingsError: Error {
    case invalidArgument(message: String)
}

public class TrimSettings: NSObject
{
    private var startsAt: CLong = 0;
    private var endsAt: CLong = 0;

    /**
     * startsAt: startsAt in miliSeconds
     * endsAt: endsAt in miliSeconds
     */
    init(startsAt: CLong, endsAt: CLong) throws
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

    /**
     * Get startsAt in miliSeconds
     * @return startsAt in miliSeconds
     */
    func getStartsAt()->CLong
    {
        return self.startsAt;
    }

    /**
     * Set startsAt in miliSeconds
     * startsAt: startsAt in miliSeconds
     */
    func setStartsAt(_ startsAt: CLong) throws
    {
        if (startsAt < 0)
        {
            throw TrimSettingsError.invalidArgument(message: "Parameter startsAt cannot be negative");
        }
        self.startsAt = startsAt;
    }

    /**
     * Get endsAt in miliSeconds
     * @return endsAt in miliSeconds
     */
    func getEndsAt()->CLong
    {
        return self.endsAt;
    }

    /**
     * Set endsAt in miliSeconds
     * endsAt: endsAt in miliSeconds
     */
    func setEndsAt(_ endsAt: CLong) throws
    {
        if (endsAt < 0)
        {
            throw TrimSettingsError.invalidArgument(message: "Parameter endsAt cannot be negative");
        }
        self.endsAt = endsAt;
    }
}
