# Travel Expense Tracking App - Requirements & Technical Recommendations

## Introduction

The goal is to build a multi‑user, multi‑tenant expense‑tracking system for long‑term travel. The tool should allow travellers to record expenses offline, split costs with companions, automatically convert currencies, and analyse spending against trip budgets. The app should be ready for commercial use by separate tenants (organisations/families), with each tenant able to configure their own categories, payment methods and budgets. Mobile support is critical and the application must work reliably when the device is offline.

## Functional requirements

### Multi‑tenant architecture

- **Separate data per tenant:** each tenant (e.g. a family, group or organisation) must have its own isolated data. Tenants should not see other tenants' expenses, categories or payment methods.
- **Configurable categories:** default categories (accommodation, transport, food/drinks, activities, shopping, health/beauty, miscellaneous) should be provided but tenants can add, rename or delete categories. Categories belong to the tenant and changes must not affect other tenants.
- **Configurable payment methods:** provide default payment methods (cash, credit card) and allow tenants to create custom methods (e.g. traveller's cheque). Each method can have an icon (font‑awesome name or uploaded image).
- **Configurable budgets:** per‑tenant budgets can be set globally (trip budget), per month, per country or per category. Budgets should accept a currency and amount. Warnings/alerts must trigger if spending exceeds a budget.

### Multi‑user and access control

- **User accounts & authentication:** support account registration/login. A user can belong to one or more tenants. Each membership has a role (e.g. owner/admin, editor, read‑only).
- **Invites:** allow tenant administrators to invite other users by email/link to join their tenant. Invited users should be able to accept and choose a password. TravelSpend's help centre notes that invites allow friends or family to enter expenses and data syncs in real‑time[\[1\]](https://travel-spend.com/#:~:text=Packed%20With%20Features).
- **Shared trips:** within a tenant, users can create trips. Multiple members can join a trip, add expenses and view statistics. Each expense stores who paid and which participants it was for. A balance view should calculate who owes whom, similar to TravelSpend's cost‑splitting feature that lets users select "Paid by" and the list of people the expense is for[\[2\]](https://travel-spend.com/blog/organize-group-bills-split-costs-with-travelspend/#:~:text=Many%20of%20you%20asked%20us,Here%20is%20how%20it%20works).
- **Personal vs shared expenses:** expenses can be tagged as personal (affecting only the payer), shared among selected travellers, or joint (e.g. "Shared account"). The app must allocate the cost according to the selected participants and reflect this in debts/balances.
- **User preferences:** users can set a home currency and additional currencies they frequently use. The sheet's _Settings_ tab shows a "Home currency" and "Additional currencies" per traveller[\[3\]](https://topflightapps.com/ideas/native-vs-progressive-web-app/#:~:text=comes%20to%20Safari%20on%20iOS).

### Trip management

- **Trips and segments:** a tenant may have multiple trips. Each trip has a name, start date and (optional) end date. A trip can be divided into segments per country or city. For each segment, store the country code, entry date and exit date, which allow the app to calculate the duration automatically as done in the sheet's _Duration_ column[\[3\]](https://topflightapps.com/ideas/native-vs-progressive-web-app/#:~:text=comes%20to%20Safari%20on%20iOS).
- **Pre‑trip expenses:** allow expenses to be logged before the trip starts (e.g. travel insurance, visas) under a "Pre‑trip" segment. These expenses should be included in totals but not in daily averages for any country.
- **Currency settings:** the trip or segment stores its default currency (usually the user's home currency) and additional currencies to make available in dropdowns. When a country is added, the app should query a country‑to‑currency table to add its currency to the list, similar to the _Countries_ sheet where each country is mapped to a currency[\[3\]](https://topflightapps.com/ideas/native-vs-progressive-web-app/#:~:text=comes%20to%20Safari%20on%20iOS).

### Expense entry

Each expense record has the following fields:

- **Date:** the date of the transaction. Users should be able to pick a date and, optionally, a time.
- **Amount & currency:** amount in the currency used at the point of purchase. The currency dropdown should include the home currency, currencies of all selected countries and any additional currencies added by the user.
- **Converted amount:** automatically convert the entered amount to the trip's home currency at the current exchange rate. TravelSpend automatically converts expenses[\[4\]](https://travel-spend.com/#:~:text=Don%27t%20worry%20about%20currencies%20exchange,rates); the new app must do the same using an exchange‑rate API (e.g. exchangeratesapi.io, Open Exchange Rates, Fixer.io). Store the rate used and allow users to override the rate manually.
- **Category & type:** select a category (e.g. "Transport") and an optional sub‑type (e.g. "Train", "Taxi"). Types help group expenses within categories.
- **Days / multi‑day expenses:** support expenses spanning multiple days. Users enter the number of days; the app divides the cost evenly over the specified days for daily metrics and budgets. The sheet's _Days_ column and _Days split_ calculation illustrate this concept[\[5\]](https://runawaytraveller.com/travelspend-app/#:~:text=Connects%20to%20ApplePay).
- **Paid by / Paid for:** select who paid the expense and for whom the expense was incurred. If there are multiple payers, the app must allow a custom split (equal or manual). TravelSpend's cost‑splitting blog post describes choosing a payer and the list of participants[\[2\]](https://travel-spend.com/blog/organize-group-bills-split-costs-with-travelspend/#:~:text=Many%20of%20you%20asked%20us,Here%20is%20how%20it%20works).
- **Payment method:** pick a payment method from the tenant's list (cash, credit card, etc.).
- **Place & location:** attach a place using the Google Maps API. By default, use the current city determined via geolocation and reverse geocoding. Store the place ID, city name and latitude/longitude for map displays and analytics (e.g. "Follow your expenses on a map"[\[6\]](https://travel-spend.com/#:~:text=Follow%20your%20expenses%20on%20a,map)).
- **Description / notes:** free‑text description.
- **Attachments:** allow attaching photos (e.g. receipts, meal pictures). Photos should be stored in the backend and cached for offline use.
- **Tags:** users may add arbitrary tags (e.g. "work", "refund"). Support filtering by tags.
- **Flags:** boolean flags such as "Is refund" (subtracts from totals), "Exclude from daily metrics" and "Exclude from all metrics". The daily metrics articles explain that excluding entries lowers the daily average and remaining daily budget[\[7\]](https://help.travel-spend.com/daily-metrics/nsEZBhRKe4aEiaHGB4fnwF/how-does-the-daily-average-work/ixayoUZqmZcxikYkFpPVf4#:~:text=This%20is%20your%20total%20spend,your%20trip%20up%20to%20today)[\[8\]](https://help.travel-spend.com/daily-metrics/nsEZBhRKe4aEiaHGB4fnwF/how-does-the-remaining-daily-budget-work/uT5EPNGKPV3AFsgGuuKQGq#:~:text=What%20happens%20if%20you%20exclude,entries%20from%20the%20daily%20metrics).

### Data import/export

- **CSV import:** users should be able to import expenses from CSV files. The import wizard must let users map columns to the app's fields (date, amount, currency, category, etc.) and decide how to handle unknown categories or currencies. Duplicate detection (via date, amount, and description) should prevent accidental double imports.
- **CSV/PDF export:** allow exporting all expenses or filtered subsets (by trip, category, date range) to CSV and PDF. Include both the original and converted amounts. TravelSpend provides CSV export for expense reports[\[9\]](https://travel-spend.com/#:~:text=Export%20your%20data).

### Offline operation

- **Full offline functionality:** users must be able to add, edit and delete expenses without an internet connection. The app should cache exchange rates (last retrieved while online) and convert currencies offline. Once the device reconnects, expenses and attachments should sync automatically. TravelSpend emphasises that expenses can be added anywhere and sync automatically when reconnected[\[10\]](https://www.thetraveler.org/travelspend-review-the-best-budget-app-for-long-term-travelers/#:~:text=Offline%20Expense%20Tracking%20%E2%80%93%20Because,Fi%20Isn%E2%80%99t%20Always%20Reliable).
- **Conflict resolution:** if multiple users edit the same expense while offline, the server should reconcile changes based on timestamps and notify users of conflicts.
- **Local storage:** use a local database (e.g. SQLite or IndexedDB) to persist all data, including attachments and exchange rates, when offline.

### Budgeting and metrics

- **Daily metrics:** compute daily average spend (total spent to date divided by number of days so far) and remaining daily budget (money left divided by days remaining). TravelSpend's help articles describe these calculations[\[7\]](https://help.travel-spend.com/daily-metrics/nsEZBhRKe4aEiaHGB4fnwF/how-does-the-daily-average-work/ixayoUZqmZcxikYkFpPVf4#:~:text=This%20is%20your%20total%20spend,your%20trip%20up%20to%20today)[\[11\]](https://help.travel-spend.com/daily-metrics/nsEZBhRKe4aEiaHGB4fnwF/how-does-the-remaining-daily-budget-work/uT5EPNGKPV3AFsgGuuKQGq#:~:text=The%20r%20emaining%20daily%20budget,the%20rest%20of%20your%20trip). Users should be able to exclude expenses from daily metrics.
- **Monthly and per‑country budgets:** support monthly and country‑specific budgets. For multi‑day expenses that span country boundaries, allocate the cost proportionally.
- **Alerts:** visual indicators and optional push notifications when spending approaches or exceeds budgets.
- **Summary & charts:** provide dashboards that summarise spending by category, type, country and month. Include charts (pie/donut for category split, bar/line charts for time series) similar to TravelSpend's pie charts[\[12\]](https://runawaytraveller.com/travelspend-app/#:~:text=Visually%20pleasing%20pie%20charts). A trip summary should show total spent, per‑category totals and averages[\[13\]](https://www.thetraveler.org/travelspend-review-the-best-budget-app-for-long-term-travelers/#:~:text=Trip%20Summaries%20%E2%80%93%20Your%20Entire,Budget%20at%20a%20Glance).
- **Maps:** display expenses on a map using stored place/location information. Users can view how much was spent in each location.[\[6\]](https://travel-spend.com/#:~:text=Follow%20your%20expenses%20on%20a,map)

### Cost splitting and settlement

- **Balances:** compute how much each traveller owes or is owed based on paid versus shared amounts. A balance view should show outstanding debts and allow marking them as settled. The TravelSpend blog post illustrates settling debts after splitting group expenses[\[14\]](https://travel-spend.com/blog/organize-group-bills-split-costs-with-travelspend/#:~:text=,Balance%20view%20of%20split%20costs).
- **Custom splits:** support unequal splits (e.g. one person pays 70 %, another 30 %). Provide an interface for entering custom percentages or amounts.
- **Settlement transactions:** allow users to record settlement payments (e.g. cash or bank transfer) to clear balances.

### Receipt scanning and automation

- **Receipt OCR:** integrate with Tabscanner or Taggun API to extract amounts, dates and merchant names from receipt images. After scanning, suggest values for expense fields and allow users to edit before saving.
- **Apple Pay/Google Pay integration:** provide optional automation to import Apple Pay transactions on iOS via Shortcuts, following TravelSpend's instructions for Apple Pay automation[\[5\]](https://runawaytraveller.com/travelspend-app/#:~:text=Connects%20to%20ApplePay). For Android, explore similar integrations or allow manual import via CSV.

### Security and compliance

- **Encryption:** sensitive data (tokens, attachments) must be encrypted in transit (HTTPS) and at rest. Do not store tokens in localStorage; use secure storage (Keychain/KeyStore) as recommended for PWAs[\[15\]](https://topflightapps.com/ideas/native-vs-progressive-web-app/#:~:text=Even%20though%20PWA%20applications%20run,effort%20to%20secure%20this%20software).
- **Authentication:** support secure password storage (bcrypt or Argon2), session management and optional two‑factor authentication. Consider social logins (Google/Apple) for ease of access.
- **Data isolation:** enforce row‑level security so that users can only access data belonging to their tenant. For self‑hosted deployments, use separate databases per tenant if required.
- **GDPR compliance:** ensure users can export or delete their data and that personal data (names, emails) is processed lawfully.

## Non‑functional requirements

- **Cross‑platform availability:** the application must run on iOS, Android and web. A desktop web version (responsive) is also required.
- **Performance:** the user interface should load quickly and remain responsive, even with thousands of expenses. Caching and pagination should be used for large datasets.
- **Reliability:** offline data must not be lost; sync processes should be robust against network interruptions. Use acknowledgements to confirm successful uploads.
- **Extensibility:** the architecture should allow adding new features (e.g. automatic categorisation, integration with bank feeds) without major refactoring.

## Recommended technical stack

### Mobile and web front‑end

The app needs offline capability, native device APIs (camera for receipts, geolocation), push notifications and installability on iOS and Android. Three main options exist:

| Option | Advantages | Disadvantages |
| --- | --- | --- |
| **Progressive Web App (PWA)** | Single codebase; runs on any modern browser; easy updates; offline via service workers; cheaper to develop. | PWAs suffer limitations on iOS: background sync is hard, offline storage is capped (~50 MB) and push notifications are not supported[\[16\]](https://topflightapps.com/ideas/native-vs-progressive-web-app/#:~:text=For%20example%3A%20on%20iOS%2C%20having,like%20any%20native%20app%E2%80%99s%20card). Access to hardware features (camera, secure storage) and in‑app payments is limited[\[17\]](https://topflightapps.com/ideas/native-vs-progressive-web-app/#:~:text=,context%20when%20opening%20a%20link). These restrictions are problematic for receipt photos, offline data and notifications. |
| **React Native** | A single JavaScript/TypeScript codebase that compiles to native iOS and Android apps. Access to device APIs (camera, geolocation, secure storage, notifications) is straightforward. Supports offline storage (SQLite) and background sync. Third‑party libraries simplify development. React Native remains easier to learn for web developers than platform‑specific languages[\[18\]](https://topflightapps.com/ideas/native-vs-progressive-web-app/#:~:text=Our%20preferred%20platform%20is%20React,the%20native%20platforms%20can%20understand). | Requires publishing via app stores (longer release cycles). Still needs some platform‑specific code (e.g. notification setup). Slightly larger initial learning curve than a PWA. |
| **Flutter** | Uses Dart and compiles to native code for iOS and Android. Provides high performance, rich widgets and strong support for offline storage. Single codebase for mobile (and experimental web/desktop). | Requires learning Dart (unfamiliar to user). Less mature ecosystem for some plugins (e.g. advanced charts, OCR). |

Given the need for offline support, camera access, secure local storage and push notifications, a pure PWA would face significant obstacles on iOS[\[16\]](https://topflightapps.com/ideas/native-vs-progressive-web-app/#:~:text=For%20example%3A%20on%20iOS%2C%20having,like%20any%20native%20app%E2%80%99s%20card). **Flutter** provides a high‑performance cross‑platform solution without relying on JavaScript/TypeScript, and its widget system makes building complex UIs straightforward. It is therefore the preferred option when Dart is acceptable. **React Native** remains a viable alternative for teams comfortable with JavaScript/TypeScript; it has a large ecosystem of libraries for maps, charts and offline storage but introduces an additional language and dependence on the React ecosystem.

**Recommendation:** implement the mobile applications using **Flutter**. Flutter uses Dart to compile directly to native code, offering high performance, a rich widget system and mature support for offline storage. A single Flutter codebase will target both iOS and Android, and Flutter Web can be used to build a basic browser‑based client for desktop users. This approach avoids JavaScript/TypeScript on the client, aligns with your interest in learning Flutter and still enables full access to native device APIs. If desired, a lightweight PWA can be built later for read‑only access or simple data entry.

### Local storage and offline sync

- Use **SQLite** or **WatermelonDB**/"react‑native‑sqlite‑storage" for local persistence of expenses, categories, payment methods and cached currency rates. These libraries support offline queries and synchronisation queues.
- Implement a **synchronisation layer** that queues operations (create/update/delete) while offline and sends them to the backend once a connection is available. This layer should handle conflict resolution based on timestamps.
- Cache exchange rates locally and update them when online; fallback to last known rate offline as TravelSpend does[\[10\]](https://www.thetraveler.org/travelspend-review-the-best-budget-app-for-long-term-travelers/#:~:text=Offline%20Expense%20Tracking%20%E2%80%93%20Because,Fi%20Isn%E2%80%99t%20Always%20Reliable).

### Backend

- **Framework:** use a mature MVC framework such as **Ruby on Rails** (the user already knows Ruby) or **Laravel** (PHP) to implement a REST/GraphQL API. Both frameworks provide strong conventions, comprehensive test harnesses and robust error handling. Rails supports multi‑tenant patterns via gems like apartment or acts_as_tenant, while Laravel offers packages like tenancy/tenancy.
- **Database:** **PostgreSQL** with row‑level security. It supports JSON fields for storing dynamic properties (e.g. tags) and can enforce tenant isolation. Use separate schemas per tenant if required.
- **Authentication:** implement token‑based authentication (e.g. JWT) or session‑based auth for web. Consider using OAuth providers (Google, Apple) for social logins.
- **Currency conversion:** integrate with an external API (e.g. exchangeratesapi.io, Open Exchange Rates or Fixer) to fetch daily rates. Cache rates in the database with timestamps.
- **File storage:** store attachments in an object store (e.g. Amazon S3, Google Cloud Storage). Use pre‑signed URLs for uploads/downloads.
- **Maps API:** use Google Maps or Mapbox for geocoding and maps. Google Maps offers detailed place data; Mapbox may have lower cost at scale.
- **Receipt OCR:** create a microservice that proxies requests to Tabscanner/Taggun. These services return JSON with parsed fields; the app can fill the expense form accordingly.
- **Notifications:** use Firebase Cloud Messaging (FCM) for Android and Apple Push Notification Service (APNS) for iOS. Backend should send notifications when budgets are exceeded or when users are invited to a trip.
- **Testing & CI:** adopt automated testing (RSpec in Rails or PHPUnit in Laravel) with coverage for API endpoints, business rules and multi‑tenant isolation. Use continuous integration pipelines (GitHub Actions/GitLab CI) to run tests and deploy.

### DevOps and deployment

- **Containerisation:** package the backend as a Docker image. Use Docker Compose or Kubernetes for multi‑service deployment (API, database, cache, worker, object storage proxy).
- **Hosting:** host on a cloud provider (e.g. AWS, GCP, DigitalOcean) with managed PostgreSQL and object storage. Ensure TLS termination and automatic backups.
- **Monitoring:** employ tools like Grafana and Prometheus to monitor request rates, error rates and latency. Implement logging (e.g. via Logstash/ELK) for debugging.

## Conclusion

The proposed application will modernise the Google Sheets solution by supporting multiple users and tenants, offline operation, cross‑platform mobile use and advanced features such as cost splitting and receipt OCR. **Flutter** is recommended for the mobile frontend because it compiles to native code, offers high performance, and avoids the need for JavaScript/TypeScript. On the server side, a Rails or Laravel backend with PostgreSQL provides a robust foundation for multi‑tenant data management. By following this specification and leveraging the cited practices from existing travel‑budgeting apps and industry guidelines, the app should deliver a reliable and extensible platform for travellers to manage expenses anywhere.

[\[1\]](https://travel-spend.com/#:~:text=Packed%20With%20Features) [\[4\]](https://travel-spend.com/#:~:text=Don%27t%20worry%20about%20currencies%20exchange,rates) [\[6\]](https://travel-spend.com/#:~:text=Follow%20your%20expenses%20on%20a,map) [\[9\]](https://travel-spend.com/#:~:text=Export%20your%20data) TravelSpend

<https://travel-spend.com/>

[\[2\]](https://travel-spend.com/blog/organize-group-bills-split-costs-with-travelspend/#:~:text=Many%20of%20you%20asked%20us,Here%20is%20how%20it%20works) [\[14\]](https://travel-spend.com/blog/organize-group-bills-split-costs-with-travelspend/#:~:text=,Balance%20view%20of%20split%20costs) Organize your group bills: use TravelSpend for cost splitting

<https://travel-spend.com/blog/organize-group-bills-split-costs-with-travelspend/>

[\[3\]](https://topflightapps.com/ideas/native-vs-progressive-web-app/#:~:text=comes%20to%20Safari%20on%20iOS) [\[15\]](https://topflightapps.com/ideas/native-vs-progressive-web-app/#:~:text=Even%20though%20PWA%20applications%20run,effort%20to%20secure%20this%20software) [\[16\]](https://topflightapps.com/ideas/native-vs-progressive-web-app/#:~:text=For%20example%3A%20on%20iOS%2C%20having,like%20any%20native%20app%E2%80%99s%20card) [\[17\]](https://topflightapps.com/ideas/native-vs-progressive-web-app/#:~:text=,context%20when%20opening%20a%20link) [\[18\]](https://topflightapps.com/ideas/native-vs-progressive-web-app/#:~:text=Our%20preferred%20platform%20is%20React,the%20native%20platforms%20can%20understand) Progressive Web Apps (PWA) vs. Native Apps in 2025: Pros And Cons

<https://topflightapps.com/ideas/native-vs-progressive-web-app/>

[\[5\]](https://runawaytraveller.com/travelspend-app/#:~:text=Connects%20to%20ApplePay) [\[12\]](https://runawaytraveller.com/travelspend-app/#:~:text=Visually%20pleasing%20pie%20charts) TravelSpend Is the Ultimate Budgeting Tool for Your Trip

<https://runawaytraveller.com/travelspend-app/>

[\[7\]](https://help.travel-spend.com/daily-metrics/nsEZBhRKe4aEiaHGB4fnwF/how-does-the-daily-average-work/ixayoUZqmZcxikYkFpPVf4#:~:text=This%20is%20your%20total%20spend,your%20trip%20up%20to%20today) How does the daily average work? - TravelSpend | Help Center

<https://help.travel-spend.com/daily-metrics/nsEZBhRKe4aEiaHGB4fnwF/how-does-the-daily-average-work/ixayoUZqmZcxikYkFpPVf4>

[\[8\]](https://help.travel-spend.com/daily-metrics/nsEZBhRKe4aEiaHGB4fnwF/how-does-the-remaining-daily-budget-work/uT5EPNGKPV3AFsgGuuKQGq#:~:text=What%20happens%20if%20you%20exclude,entries%20from%20the%20daily%20metrics) [\[11\]](https://help.travel-spend.com/daily-metrics/nsEZBhRKe4aEiaHGB4fnwF/how-does-the-remaining-daily-budget-work/uT5EPNGKPV3AFsgGuuKQGq#:~:text=The%20r%20emaining%20daily%20budget,the%20rest%20of%20your%20trip) How does the remaining daily budget work? - TravelSpend | Help Center

<https://help.travel-spend.com/daily-metrics/nsEZBhRKe4aEiaHGB4fnwF/how-does-the-remaining-daily-budget-work/uT5EPNGKPV3AFsgGuuKQGq>

[\[10\]](https://www.thetraveler.org/travelspend-review-the-best-budget-app-for-long-term-travelers/#:~:text=Offline%20Expense%20Tracking%20%E2%80%93%20Because,Fi%20Isn%E2%80%99t%20Always%20Reliable) [\[13\]](https://www.thetraveler.org/travelspend-review-the-best-budget-app-for-long-term-travelers/#:~:text=Trip%20Summaries%20%E2%80%93%20Your%20Entire,Budget%20at%20a%20Glance) TravelSpend Review: The Best Budget App for Long-Term Travelers?

<https://www.thetraveler.org/travelspend-review-the-best-budget-app-for-long-term-travelers/>
