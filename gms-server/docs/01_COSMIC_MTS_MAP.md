# COSMIC MTS / Maple Trading System Map

Scope: MTS / Maple Trading System / auction / cash shop related call chain.

Rule used in this map: when the code does not prove a detail, it is marked `UNKNOWN`.

## 1. Entry Points, Handlers, Packet Creators, Services, DAO, Tables

### Inbound entry points

| Area | Opcode | Handler | Evidence |
|---|---:|---|---|
| Enter MTS | `RecvOpcode.ENTER_MTS(0x9C)` | `EnterMTSHandler` | `PacketProcessor` registers `RecvOpcode.ENTER_MTS` to `new EnterMTSHandler()` at `src/main/java/net/PacketProcessor.java:351`; opcode value is defined at `src/main/java/net/opcodes/RecvOpcode.java:158`. |
| MTS operation | `RecvOpcode.MTS_OPERATION(0xFD)` | `MTSHandler` | `PacketProcessor` registers `RecvOpcode.MTS_OPERATION` to `new MTSHandler()` at `src/main/java/net/PacketProcessor.java:384`; opcode value is defined at `src/main/java/net/opcodes/RecvOpcode.java:203`. |
| Cash shop operation, shared context | `RecvOpcode.CASHSHOP_OPERATION(0xE5)` | `CashOperationHandler` | Registered at `src/main/java/net/PacketProcessor.java:368`; opcode value at `src/main/java/net/opcodes/RecvOpcode.java:198`. |

### Outbound packet creators

| Packet creator | Send opcode / sub-op | Purpose | Evidence |
|---|---:|---|---|
| `PacketCreator.openCashShop(c, true)` | `SendOpcode.SET_ITC(0x7E)` | Opens MTS/ITC UI | Method chooses `SET_ITC` when `mts == true` at `src/main/java/tools/PacketCreator.java:7184`; opcode value at `src/main/java/net/opcodes/SendOpcode.java:155`. |
| `PacketCreator.sendMTS(...)` | `SendOpcode.MTS_OPERATION(0x15C)`, sub-op `0x15` | Sends MTS item page | `src/main/java/tools/PacketCreator.java:5446-5470`; opcode value at `src/main/java/net/opcodes/SendOpcode.java:352`. |
| `PacketCreator.showMTSCash(chr)` | `SendOpcode.MTS_OPERATION2(0x15B)` | Sends NX Prepaid and Maple Point balances | `src/main/java/tools/PacketCreator.java:5604-5608`; opcode value at `src/main/java/net/opcodes/SendOpcode.java:351`. |
| `PacketCreator.MTSWantedListingOver(nx, items)` | `MTS_OPERATION`, sub-op `0x3D` | Wanted listing header | `src/main/java/tools/PacketCreator.java:5611-5616`. |
| `PacketCreator.MTSConfirmSell()` | `MTS_OPERATION`, sub-op `0x1D` | Sell/list success | `src/main/java/tools/PacketCreator.java:5619-5622`. |
| `PacketCreator.MTSConfirmBuy()` | `MTS_OPERATION`, sub-op `0x33` | Buy success | `src/main/java/tools/PacketCreator.java:5625-5628`. |
| `PacketCreator.MTSFailBuy()` | `MTS_OPERATION`, sub-op `0x34`, code `0x42` | Buy failure | `src/main/java/tools/PacketCreator.java:5631-5635`. |
| `PacketCreator.MTSConfirmTransfer(quantity, pos)` | `MTS_OPERATION`, sub-op `0x27` | Transfer item from transfer inventory | `src/main/java/tools/PacketCreator.java:5638-5643`. |
| `PacketCreator.notYetSoldInv(items)` | `MTS_OPERATION`, sub-op `0x23` | Not-yet-sold panel | `src/main/java/tools/PacketCreator.java:5646-5667`. |
| `PacketCreator.transferInventory(items)` | `MTS_OPERATION`, sub-op `0x21` | Transfer inventory panel | `src/main/java/tools/PacketCreator.java:5670-5691`. |

### Data/service/DAO classes

| Class / layer | Role | Evidence |
|---|---|---|
| `server.MTSItemInfo` | DTO for MTS listed/transfer items: item, price, seller, MTS row id, ending date | Fields and constructor at `src/main/java/server/MTSItemInfo.java:33-53`; getters at `src/main/java/server/MTSItemInfo.java:55-79`. |
| `server.CashShop` | Shared cash state and cash inventory. MTS uses `CashShop.NX_PREPAID` and `CashShop.MAPLE_POINT` | Constants at `src/main/java/server/CashShop.java:64-66`; cash getters/update at `src/main/java/server/CashShop.java:320-335`; opened flag at `src/main/java/server/CashShop.java:345-350`. |
| DAO | `UNKNOWN`: no dedicated MTS DAO class found. MTS handlers execute SQL directly through `DatabaseConnection`. | `MTSHandler` imports `tools.DatabaseConnection` at `src/main/java/net/server/channel/handlers/MTSHandler.java:41`; `EnterMTSHandler` imports it at `src/main/java/net/server/channel/handlers/EnterMTSHandler.java:35`. |
| Service | `UNKNOWN`: no dedicated MTS service class found. | MTS handler logic is implemented directly in `MTSHandler.handlePacket` starting at `src/main/java/net/server/channel/handlers/MTSHandler.java:57`. |

### SQL tables

| Table | Fields | Evidence |
|---|---|---|
| `mts_cart` | `id`, `cid`, `itemid` | `src/main/resources/db/tables/019-mts.sql:1-7`. |
| `mts_items` | `id`, `tab`, `type`, `itemid`, `quantity`, `seller`, `price`, `bid_incre`, `buy_now`, `position`, `upgradeslots`, `level`, `itemlevel`, `itemexp`, `ringid`, `str`, `dex`, `int`, `luk`, `hp`, `mp`, `watk`, `matk`, `wdef`, `mdef`, `acc`, `avoid`, `hands`, `speed`, `jump`, `locked`, `isequip`, `owner`, `sellername`, `sell_ends`, `transfer`, `vicious`, `flag`, `expiration`, `giftFrom` | `src/main/resources/db/tables/019-mts.sql:9-52`. |
| `accounts` | MTS uses `id`, `nxCredit`, `maplePoint`, `nxPrepaid`; purchases update `nxPrepaid` | Table fields at `src/main/resources/db/tables/001-account.sql:1-38`; MTS offline seller update at `src/main/java/net/server/channel/handlers/MTSHandler.java:420-423` and `src/main/java/net/server/channel/handlers/MTSHandler.java:473-476`. |
| `characters` | MTS uses `id`, `accountid` to resolve offline seller account | Fields at `src/main/resources/db/tables/002-character.sql:1-84`; MTS query at `src/main/java/net/server/channel/handlers/MTSHandler.java:416-419` and `src/main/java/net/server/channel/handlers/MTSHandler.java:469-472`. |
| `inventoryitems` / `inventoryequipment` | Cash shop inventory persistence, not direct MTS listing table | Fields at `src/main/resources/db/tables/003-inventory.sql:1-48`; CashShop saves via `factory.saveItems(...)` at `src/main/java/server/CashShop.java:492-499`. |
| `wishlists`, `specialcashitems`, `gifts` | Cash Shop related, shared subsystem, not direct MTS operation tables | `wishlists` and `specialcashitems` at `src/main/resources/db/tables/013-cashshop.sql:1-16`; `gifts` at `src/main/resources/db/tables/014-gift.sql:1-10`; `CashShop` loads/saves wishlists at `src/main/java/server/CashShop.java:117-124` and `src/main/java/server/CashShop.java:501-513`; gifts at `src/main/java/server/CashShop.java:415-467`. |

## 2. MTS Operation Flows

### 2.1 Open MTS

Inbound:
- Opcode: `ENTER_MTS(0x9C)`.
- Read fields: `UNKNOWN`; `EnterMTSHandler.handlePacket` does not read from `InPacket p`.
- Evidence: handler signature at `src/main/java/net/server/channel/handlers/EnterMTSHandler.java:49`; no `p.read...` in the shown method before UI open at `src/main/java/net/server/channel/handlers/EnterMTSHandler.java:52-172`.

Flow:
1. Guard `USE_MTS`; if disabled, sends `enableActions` and returns. Evidence: `src/main/java/net/server/channel/handlers/EnterMTSHandler.java:52-55`.
2. Guard event instance, mini-dungeon, field limit, alive, level >= 10. Evidence: `src/main/java/net/server/channel/handlers/EnterMTSHandler.java:57-83`.
3. Close interactions and cancel/transfer player runtime state: player interactions, party search, chair buff, buffs/diseases storage, away-from-world flag, invites, buffs/debuffs/cooldowns/expiration/quest tasks. Evidence: `src/main/java/net/server/channel/handlers/EnterMTSHandler.java:85-102`.
4. Save character, remove from channel and map. Evidence: `src/main/java/net/server/channel/handlers/EnterMTSHandler.java:104-107`.
5. Send `PacketCreator.openCashShop(c, true)`, which emits `SET_ITC`. Evidence: call at `src/main/java/net/server/channel/handlers/EnterMTSHandler.java:108-112`; packet creator at `src/main/java/tools/PacketCreator.java:7184-7201`.
6. Mark CashShop opened with `chr.getCashShop().open(true)` and enable CS actions. Evidence: `src/main/java/net/server/channel/handlers/EnterMTSHandler.java:113-114`.
7. Send wanted listing header, cash balance, first item page, transfer inventory, not-yet-sold inventory. Evidence: `src/main/java/net/server/channel/handlers/EnterMTSHandler.java:115-172`.

SQL:
- Initial visible list: `SELECT * FROM mts_items WHERE tab = 1 AND transfer = 0 ORDER BY id DESC LIMIT 16, 16`. Evidence: `src/main/java/net/server/channel/handlers/EnterMTSHandler.java:119-121`.
- Page count: `SELECT COUNT(*) FROM mts_items`. Evidence: `src/main/java/net/server/channel/handlers/EnterMTSHandler.java:161-165`.
- Not-yet-sold: `SELECT * FROM mts_items WHERE seller = ? AND transfer = 0 ORDER BY id DESC`. Evidence: `src/main/java/net/server/channel/handlers/EnterMTSHandler.java:175-178`.
- Transfer inventory: `SELECT * FROM mts_items WHERE transfer = 1 AND seller = ? ORDER BY id DESC`. Evidence: `src/main/java/net/server/channel/handlers/EnterMTSHandler.java:225-228`.

Outbound:
- `SET_ITC(0x7E)` writes character info, account name, and fixed MTS bytes. Evidence: `src/main/java/tools/PacketCreator.java:7184-7201`.
- `MTSWantedListingOver`: writes `0x3D`, `nx`, `items`. Evidence: `src/main/java/tools/PacketCreator.java:5611-5616`.
- `showMTSCash`: writes NX prepaid and Maple Point. Evidence: `src/main/java/tools/PacketCreator.java:5604-5608`.
- `sendMTS`: writes sub-op `0x15`, total count, item count, tab, type, page, item rows. Evidence: `src/main/java/tools/PacketCreator.java:5446-5470`.

### 2.2 Search

Inbound:
- Opcode: `MTS_OPERATION(0xFD)`.
- Sub-op: `6`.
- Read fields: `tab:int`, `type:int`, one unused `int` (`UNKNOWN` meaning), `ci:int`, `search:String`.
- Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:232-237`.

Flow:
1. Store search string/current tab/type/current CI on player. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:238-241`.
2. Enable CS actions, send enableActions, call `getMTSSearch(tab, type, ci, search, currentPage)`. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:242-244`.
3. Refresh cash balance, transfer inventory, and not-yet-sold inventory. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:245-247`.

SQL:
- If `ci != 0`, item-name search scans `ItemInformationProvider.getAllItems()` and builds an `itemid = ... OR ...` SQL fragment. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:757-774`.
- If `ci == 0`, seller-name search builds `sellername LIKE CONCAT('%','" + search + "', '%')`. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:775-777`.
- Query: `SELECT * FROM mts_items WHERE tab = ? [listaitems] AND [type = ?] AND transfer = 0 ORDER BY id DESC LIMIT ?, 16`. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:780-794`.
- Count query: `SELECT COUNT(*) FROM mts_items WHERE tab = ? [listaitems] AND transfer = 0`. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:832-845`.

Outbound:
- Main search result uses `PacketCreator.sendMTS(...)`. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:850`; packet fields at `src/main/java/tools/PacketCreator.java:5446-5470`.
- Cash/transfer/not-yet-sold refresh as listed above. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:245-247`.

Security note:
- Seller-name search concatenates user-provided `search` into SQL. This conclusion is directly from `src/main/java/net/server/channel/handlers/MTSHandler.java:776`.

### 2.3 List Item For Sale

Inbound:
- Opcode: `MTS_OPERATION(0xFD)`.
- Sub-op: `2`.
- Read fields:
  - `itemtype:byte`
  - `itemid:int`
  - unused `short` (`UNKNOWN`)
  - skip 7 bytes (`UNKNOWN`)
  - for equip `itemtype == 1`, skip 32 bytes (`UNKNOWN`); for non-equip, read `stars:short`
  - `owner:String`, explicitly commented useless
  - for equip, skip another 32 bytes (`UNKNOWN`); for non-equip, read unused `short` (`UNKNOWN`)
  - `slot:int`
  - `quantity:int`, except rechargeable uses `stars`; equip quantity forced to 1
  - `price:int`
- Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:67-106`.

Flow:
1. Validate quantity, minimum price 110, and player item quantity. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:108-110`.
2. Resolve inventory type and copy item from slot. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:111-112`.
3. Require item copy and at least 5000 mesos. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:113`.
4. Count seller listings using `SELECT COUNT(*) FROM mts_items WHERE seller = ?`; if more than 10, reject and refresh panels. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:114-124`.
5. Compute `sell_ends` as current date plus 7 days formatted `yyyy-MM-dd`. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:128-131`.
6. Insert non-equip or equip row into `mts_items`. Evidence: non-equip insert at `src/main/java/net/server/channel/handlers/MTSHandler.java:133-148`; equip insert at `src/main/java/net/server/channel/handlers/MTSHandler.java:149-187`.
7. Remove listed item from inventory, deduct 5000 mesos, send confirmation and refresh panels. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:189-199`.

SQL fields written:
- Non-equip insert writes `tab`, `type`, `itemid`, `quantity`, `expiration`, `giftFrom`, `seller`, `price`, `owner`, `sellername`, `sell_ends`. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:135-147`.
- Equip insert writes `tab`, `type`, `itemid`, `quantity`, `expiration`, `giftFrom`, `seller`, `price`, `upgradeslots`, `level`, `str`, `dex`, `int`, `luk`, `hp`, `mp`, `watk`, `matk`, `wdef`, `mdef`, `acc`, `avoid`, `hands`, `speed`, `jump`, `locked`, `owner`, `sellername`, `sell_ends`, `vicious`, `flag`, `itemexp`, `itemlevel`, `ringid`. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:151-186`.

Outbound:
- `MTSConfirmSell` writes sub-op `0x1D`. Evidence: `src/main/java/tools/PacketCreator.java:5619-5622`.
- Refresh list via `getMTS(...)` then `transferInventory(...)` and `notYetSoldInv(...)`. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:195-199`.

### 2.4 Buy

Inbound:
- Direct buy opcode: `MTS_OPERATION(0xFD)`, sub-op `16`.
- Cart buy opcode: `MTS_OPERATION(0xFD)`, sub-op `17`.
- Read fields: `id:int` for both.
- Evidence: direct buy at `src/main/java/net/server/channel/handlers/MTSHandler.java:398-401`; cart buy at `src/main/java/net/server/channel/handlers/MTSHandler.java:455-458`.

Flow:
1. Query item row: `SELECT * FROM mts_items WHERE id = ? ORDER BY id DESC`. Evidence: direct buy at `src/main/java/net/server/channel/handlers/MTSHandler.java:400-403`; cart buy at `src/main/java/net/server/channel/handlers/MTSHandler.java:457-460`.
2. Compute buyer charge as `price + 100 + price * 0.1`. Evidence: direct buy at `src/main/java/net/server/channel/handlers/MTSHandler.java:405`; cart buy at `src/main/java/net/server/channel/handlers/MTSHandler.java:462`.
3. Require buyer `CashShop.NX_PREPAID` balance to cover charge. Evidence: direct buy at `src/main/java/net/server/channel/handlers/MTSHandler.java:406`; cart buy at `src/main/java/net/server/channel/handlers/MTSHandler.java:463`.
4. Online seller: find seller across all channels and add raw `price` to seller `CashShop.NX_PREPAID`. Evidence: direct buy at `src/main/java/net/server/channel/handlers/MTSHandler.java:408-413`; cart buy at `src/main/java/net/server/channel/handlers/MTSHandler.java:464-468`.
5. Offline seller: resolve `characters.accountid`, then `UPDATE accounts SET nxPrepaid = nxPrepaid + ? WHERE id = ?`. Evidence: direct buy at `src/main/java/net/server/channel/handlers/MTSHandler.java:415-426`; cart buy at `src/main/java/net/server/channel/handlers/MTSHandler.java:469-479`.
6. Transfer item ownership by changing `mts_items.seller` to buyer id and `transfer = 1`. Evidence: direct buy at `src/main/java/net/server/channel/handlers/MTSHandler.java:428-431`; cart buy at `src/main/java/net/server/channel/handlers/MTSHandler.java:482-485`.
7. Delete any cart rows for the item. Evidence: direct buy at `src/main/java/net/server/channel/handlers/MTSHandler.java:433-436`; cart buy at `src/main/java/net/server/channel/handlers/MTSHandler.java:487-490`.
8. Deduct buyer charged price from `CashShop.NX_PREPAID`. Evidence: direct buy at `src/main/java/net/server/channel/handlers/MTSHandler.java:437`; cart buy at `src/main/java/net/server/channel/handlers/MTSHandler.java:491`.

Outbound:
- Success: `MTSConfirmBuy` sub-op `0x33`, then cash balance and panels. Evidence: direct buy at `src/main/java/net/server/channel/handlers/MTSHandler.java:438-444`; cart buy at `src/main/java/net/server/channel/handlers/MTSHandler.java:492-497`; packet creator at `src/main/java/tools/PacketCreator.java:5625-5628`.
- Failure: `MTSFailBuy` sub-op `0x34`, code `0x42`. Evidence: direct buy at `src/main/java/net/server/channel/handlers/MTSHandler.java:445-451`; cart buy at `src/main/java/net/server/channel/handlers/MTSHandler.java:498-504`; packet creator at `src/main/java/tools/PacketCreator.java:5631-5635`.

### 2.5 Cancel Listing

Inbound:
- Opcode: `MTS_OPERATION(0xFD)`.
- Sub-op: `7`.
- Read fields: `id:int`.
- Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:250-251`.

Flow:
1. Mark seller-owned row as transfer inventory: `UPDATE mts_items SET transfer = 1 WHERE id = ? AND seller = ?`. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:252-257`.
2. Remove cart references: `DELETE FROM mts_cart WHERE itemid = ?`. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:259-262`.
3. Refresh current MTS page, not-yet-sold, transfer inventory. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:266-270`.

Outbound:
- No dedicated cancel-confirm packet is emitted in the shown code. `UNKNOWN` if client expects a distinct cancel confirmation beyond refreshed panels.
- Evidence: case `7` only sends `getMTS`, `notYetSoldInv`, and `transferInventory` at `src/main/java/net/server/channel/handlers/MTSHandler.java:266-270`.

### 2.6 Claim Proceeds

Conclusion:
- `UNKNOWN` as a separate MTS operation. No handler case implements manual "claim proceeds" semantics.
- Sale proceeds are credited during purchase:
  - Online seller: `victim.getCashShop().gainCash(4, rs.getInt("price"))`. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:408-413`.
  - Offline seller: `UPDATE accounts SET nxPrepaid = nxPrepaid + ? WHERE id = ?`. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:420-423`.
- `CashShop.gainCash` mutates `nxPrepaid` for `CashShop.NX_PREPAID`. Evidence: `src/main/java/server/CashShop.java:330-335`.

Related but not proceeds:
- Sub-op `8` transfers an item from transfer inventory into the player's normal inventory. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:273-333`.
- It reads `id:int`, selects `mts_items WHERE seller = ? AND transfer = 1 AND id = ?`, rebuilds item/equip, deletes the `mts_items` row, adds item to inventory, and sends `MTSConfirmTransfer(quantity,pos)`. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:273-333`.

## 3. Auction / Wanted Status

| Operation | Code status | Evidence |
|---|---|---|
| Send offer for wanted item | `case 3` only breaks | `src/main/java/net/server/channel/handlers/MTSHandler.java:203-204`. |
| List wanted item | `case 4` reads three ints, one short, one string, then breaks; semantics `UNKNOWN` | `src/main/java/net/server/channel/handlers/MTSHandler.java:205-211`. |
| Put item up for auction | `case 12` only breaks | `src/main/java/net/server/channel/handlers/MTSHandler.java:392-393`. |
| Cancel wanted cart thing | `case 13` only breaks | `src/main/java/net/server/channel/handlers/MTSHandler.java:394-395`. |
| Buy auction item now | `case 14` only breaks | `src/main/java/net/server/channel/handlers/MTSHandler.java:396-397`. |
| Auction fields in DB | `bid_incre`, `buy_now` exist but handler does not implement auction behavior | `src/main/resources/db/tables/019-mts.sql:18-19`. |

## 4. Item Reconstruction From MTS Rows

MTS rows are converted back into `Item` / `Equip` in several duplicated places.

### Non-equip

Fields read:
- `itemid`, `quantity`, `owner`; sometimes position is assigned to next free slot on transfer.
- Evidence: initial open `src/main/java/net/server/channel/handlers/EnterMTSHandler.java:123-126`; transfer item `src/main/java/net/server/channel/handlers/MTSHandler.java:281-288`; list page `src/main/java/net/server/channel/handlers/MTSHandler.java:701-705`; search `src/main/java/net/server/channel/handlers/MTSHandler.java:796-799`.

### Equip

Fields read:
- `itemid`, `position`, `owner`, `quantity`, `acc`, `avoid`, `dex`, `hands`, `hp`, `int`, `jump`, `vicious`, `flag`, `luk`, `matk`, `mdef`, `mp`, `speed`, `str`, `watk`, `wdef`, `upgradeslots`, `level`, `itemlevel`, `itemexp`, `ringid`, `expiration`, `giftFrom`.
- Evidence: initial open `src/main/java/net/server/channel/handlers/EnterMTSHandler.java:128-156`; transfer item `src/main/java/net/server/channel/handlers/MTSHandler.java:290-320`; not-yet-sold `src/main/java/net/server/channel/handlers/MTSHandler.java:529-556`; transfer inventory `src/main/java/net/server/channel/handlers/MTSHandler.java:645-672`; list page `src/main/java/net/server/channel/handlers/MTSHandler.java:707-734`; search `src/main/java/net/server/channel/handlers/MTSHandler.java:801-828`.

## 5. Item Serialization Functions

### `PacketCreator.addItemInfo`

Used by MTS item pages and panels:
- `sendMTS` calls `addItemInfo(p, item.getItem(), true)`. Evidence: `src/main/java/tools/PacketCreator.java:5456-5458`.
- `notYetSoldInv` calls it. Evidence: `src/main/java/tools/PacketCreator.java:5651-5653`.
- `transferInventory` calls it. Evidence: `src/main/java/tools/PacketCreator.java:5675-5677`.

Fields written:
- Common: optional position, item type, item id, cash flag, cash/pet/ring id for cash items, expiration. Evidence: `src/main/java/tools/PacketCreator.java:400-428`.
- Pet branch: pet name, level, tameness, fullness, expiration, pet attributes, skill/remain life/attribute. Evidence: `src/main/java/tools/PacketCreator.java:429-440`.
- Non-equip: quantity, owner, flag, rechargeable extra bytes. Evidence: `src/main/java/tools/PacketCreator.java:442-451`.
- Equip: upgrade slots, level, str, dex, int, luk, hp, mp, watk, matk, wdef, mdef, acc, avoid, hands, speed, jump, owner, flag, cash padding or equip item level/exp logic. Evidence: `src/main/java/tools/PacketCreator.java:453-480`.

### `PacketCreator.addCashItemInformation`

Cash Shop serialization, related subsystem:
- Writes cash id / pet id / ring id, account id, unknown int 0, item id, SN, quantity, giftFrom, optional gift message, expiration, trailing long 0. Evidence: `src/main/java/tools/PacketCreator.java:6952-6981`.
- Used by Cash Shop inventory/gift/purchase packets, not by MTS listing packets. Evidence: calls at `src/main/java/tools/PacketCreator.java:7087-7088`, `src/main/java/tools/PacketCreator.java:7103-7104`, `src/main/java/tools/PacketCreator.java:7175-7179`.

## 6. Shared Cash Shop Behavior Used By MTS

- `Character` owns a `CashShop` instance. Evidence: field at `src/main/java/client/Character.java:273`; initialized at `src/main/java/client/Character.java:7111`.
- MTS enters the same away-from-world state as Cash Shop. Evidence: comment at `src/main/java/client/Character.java:246`; MTS enter calls `chr.setAwayFromChannelWorld()` at `src/main/java/net/server/channel/handlers/EnterMTSHandler.java:91`.
- `CashShop` loads balances from `accounts.nxCredit`, `accounts.maplePoint`, `accounts.nxPrepaid`. Evidence: `src/main/java/server/CashShop.java:100-109`.
- `CashShop.save` writes balances back to `accounts` and saves cash inventory/wishlist. Evidence: `src/main/java/server/CashShop.java:483-515`.
- MTS uses `NX_PREPAID` for purchase charging and seller proceeds. Evidence: `CashShop.NX_PREPAID` at `src/main/java/server/CashShop.java:66`; buy flow at `src/main/java/net/server/channel/handlers/MTSHandler.java:405-437` and `src/main/java/net/server/channel/handlers/MTSHandler.java:462-491`.

## 7. MTS SQL Summary

| Operation | SQL | Evidence |
|---|---|---|
| Open page | `SELECT * FROM mts_items WHERE tab = 1 AND transfer = 0 ORDER BY id DESC LIMIT 16, 16` | `src/main/java/net/server/channel/handlers/EnterMTSHandler.java:119-121`. |
| Open count | `SELECT COUNT(*) FROM mts_items` | `src/main/java/net/server/channel/handlers/EnterMTSHandler.java:161-165`. |
| General page | `SELECT * FROM mts_items WHERE tab = ? AND [type = ?] AND transfer = 0 ORDER BY id DESC LIMIT ?, 16` | `src/main/java/net/server/channel/handlers/MTSHandler.java:681-699`. |
| General page count | `SELECT COUNT(*) FROM mts_items WHERE tab = ? [AND type = ?] AND transfer = 0` | `src/main/java/net/server/channel/handlers/MTSHandler.java:738-750`. |
| Search page | `SELECT * FROM mts_items WHERE tab = ? [listaitems] AND [type = ?] AND transfer = 0 ORDER BY id DESC LIMIT ?, 16` | `src/main/java/net/server/channel/handlers/MTSHandler.java:780-794`. |
| Search count | `SELECT COUNT(*) FROM mts_items WHERE tab = ? [listaitems] AND transfer = 0` | `src/main/java/net/server/channel/handlers/MTSHandler.java:832-845`. |
| Seller listing limit | `SELECT COUNT(*) FROM mts_items WHERE seller = ?` | `src/main/java/net/server/channel/handlers/MTSHandler.java:114-119`. |
| Insert non-equip listing | `INSERT INTO mts_items (...) VALUES (...)` | `src/main/java/net/server/channel/handlers/MTSHandler.java:135-147`. |
| Insert equip listing | `INSERT INTO mts_items (...) VALUES (...)` | `src/main/java/net/server/channel/handlers/MTSHandler.java:151-186`. |
| Cancel listing | `UPDATE mts_items SET transfer = 1 WHERE id = ? AND seller = ?` | `src/main/java/net/server/channel/handlers/MTSHandler.java:253-256`. |
| Remove cart refs on cancel | `DELETE FROM mts_cart WHERE itemid = ?` | `src/main/java/net/server/channel/handlers/MTSHandler.java:259-261`. |
| Transfer item select | `SELECT * FROM mts_items WHERE seller = ? AND transfer = 1 AND id= ? ORDER BY id DESC` | `src/main/java/net/server/channel/handlers/MTSHandler.java:275-279`. |
| Transfer item delete | `DELETE FROM mts_items WHERE id = ? AND seller = ? AND transfer = 1` | `src/main/java/net/server/channel/handlers/MTSHandler.java:322-326`. |
| Add cart guard | `SELECT id FROM mts_items WHERE id = ? AND seller <> ?` | `src/main/java/net/server/channel/handlers/MTSHandler.java:344-349`. |
| Add cart duplicate check | `SELECT cid FROM mts_cart WHERE cid = ? AND itemid = ?` | `src/main/java/net/server/channel/handlers/MTSHandler.java:350-354`. |
| Add cart | `INSERT INTO mts_cart (cid, itemid) VALUES (?, ?)` | `src/main/java/net/server/channel/handlers/MTSHandler.java:355-358`. |
| Delete cart item | `DELETE FROM mts_cart WHERE itemid = ? AND cid = ?` | `src/main/java/net/server/channel/handlers/MTSHandler.java:377-381`. |
| Buy select | `SELECT * FROM mts_items WHERE id = ? ORDER BY id DESC` | `src/main/java/net/server/channel/handlers/MTSHandler.java:400-403` and `src/main/java/net/server/channel/handlers/MTSHandler.java:457-460`. |
| Offline seller account lookup | `SELECT accountid FROM characters WHERE id = ?` | `src/main/java/net/server/channel/handlers/MTSHandler.java:416-419` and `src/main/java/net/server/channel/handlers/MTSHandler.java:469-472`. |
| Offline seller proceeds | `UPDATE accounts SET nxPrepaid = nxPrepaid + ? WHERE id = ?` | `src/main/java/net/server/channel/handlers/MTSHandler.java:420-423` and `src/main/java/net/server/channel/handlers/MTSHandler.java:473-476`. |
| Buy transfer ownership | `UPDATE mts_items SET seller = ?, transfer = 1 WHERE id = ?` | `src/main/java/net/server/channel/handlers/MTSHandler.java:428-431` and `src/main/java/net/server/channel/handlers/MTSHandler.java:482-485`. |
| Remove cart refs on buy | `DELETE FROM mts_cart WHERE itemid = ?` | `src/main/java/net/server/channel/handlers/MTSHandler.java:433-436` and `src/main/java/net/server/channel/handlers/MTSHandler.java:487-490`. |
| Cart list | `SELECT * FROM mts_cart WHERE cid = ? ORDER BY id DESC`; then per row `SELECT * FROM mts_items WHERE id = ?` | `src/main/java/net/server/channel/handlers/MTSHandler.java:568-575`. |
| Cart count | `SELECT COUNT(*) FROM mts_cart WHERE cid = ?` | `src/main/java/net/server/channel/handlers/MTSHandler.java:617-626`. |

## 8. Unknowns / Non-Implemented Areas

- Meaning of several skipped/listing fields in sub-op `2` is `UNKNOWN`; the handler skips or reads-and-discards them without naming them. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:70-83`.
- Meaning of the third int in search sub-op `6` is `UNKNOWN`; it is read and discarded. Evidence: `src/main/java/net/server/channel/handlers/MTSHandler.java:233-236`.
- Manual "claim proceeds" operation is `UNKNOWN` / not implemented as a separate MTS action; sale proceeds are credited during buy. Evidence: buy proceeds at `src/main/java/net/server/channel/handlers/MTSHandler.java:408-426` and `src/main/java/net/server/channel/handlers/MTSHandler.java:464-479`.
- Auction operations are not implemented despite DB fields. Evidence: handler break-only cases at `src/main/java/net/server/channel/handlers/MTSHandler.java:392-397`; fields at `src/main/resources/db/tables/019-mts.sql:18-19`.
