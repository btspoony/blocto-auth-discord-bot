import HyperverseAuth from 0x4e190c2eb6d78faa
import HyperverseModule from 0x4e190c2eb6d78faa
import IHyperverse from 0x4e190c2eb6d78faa
pub contract EmeraldAuthBot: IHyperverse {

    /**************************************** METADATA & TENANT ****************************************/

    pub var metadata: HyperverseModule.Metadata

    pub event TenantCreated(tenant: Address)
    access(contract) var tenants: {Address: Tenant}
    access(contract) fun getTenant(_ tenant: Address): Tenant? {
        return self.tenants[tenant]
    }
    pub fun tenantExists(tenant: Address): Bool {
        return self.tenants[tenant] != nil
    }

    pub struct Tenant {
        pub var tenant: Address
        access(contract) var guilds: {String: GuildInfo}
        
        init(_tenant: Address) {
            self.tenant = _tenant
            self.guilds = {}
        }
    }

    pub fun createTenant(auth: &HyperverseAuth.Auth) {
        let tenant = auth.owner!.address
        self.tenants[tenant] = Tenant(_tenant: tenant)
        emit TenantCreated(tenant: tenant)
    }

    /**************************************** FUNCTIONALITY ****************************************/

    pub event AddedGuild(_ tenant: Address, guildID: String)

    pub struct GuildInfo {
        pub var guildID: String
        pub var tokenType: String
        pub var number: Int
        pub var path: String 
        pub var role: String
        pub var mintURL: String

        init(_guildID: String, _tokenType: String, _number: Int, _path: String, _role: String, _mintURL: String) {
            self.guildID = _guildID
            self.tokenType = _tokenType
            self.number = _number
            self.path = _path
            self.role = _role
            self.mintURL = _mintURL
        }
    }

    pub resource Headmaster {
        pub var tenant: Address
        pub fun addGuild(guildID: String, tokenType: String, number: Int, path: String, role: String, mintURL: String) {
            let state = EmeraldAuthBot.getTenant(self.tenant)!
            state.guilds[guildID] = GuildInfo(_guildID: guildID, _tokenType: tokenType, _number: number, _path: path, _role: role, _mintURL: mintURL)
            emit AddedGuild(self.tenant, guildID: guildID)
        }
        init(_ tenant: Address) { self.tenant = tenant }
    }
    pub fun createHeadmaster(auth: &HyperverseAuth.Auth): @Headmaster { return <- create Headmaster(auth.owner!.address) }

    pub fun getGuildInfo(_ tenant: Address, guildID: String): GuildInfo? {
        if let state = self.getTenant(tenant) {
            return state.guilds[guildID]
        } else {
            return nil
        }
    }

    pub fun getMintURL(_ tenant: Address, guildID: String): String? {
        if let state = self.getTenant(tenant) {
            return state.guilds[guildID]?.mintURL
        } else {
            return nil
        }
    }

    pub fun getGuildIDs(_ tenant: Address): [String] {
        if let state = self.getTenant(tenant) {
            return state.guilds.keys
        } else {
            return []
        }
    }

    init() {
        self.tenants = {}

        self.metadata = HyperverseModule.Metadata(
                            _identifier: self.getType().identifier,
                            _contractAddress: self.account.address,
                            _title: "EmeraldAuthBot",
                            _authors: [HyperverseModule.Author(_address: 0x6c0d53c676256e8c, _externalURI: "https://twitter.com/jacobmtucker")],
                            _version: "0.0.1",
                            _publishedAt: getCurrentBlock().timestamp,
                            externalURI: "https://emerald-city.netlify.app/"
                        )
    }
}