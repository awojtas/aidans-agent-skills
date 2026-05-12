# SOLID — Applied

Robert C. Martin, defending SOLID's relevance, makes the case that *"simplicity requires disciplines guided by principles."* SOLID is the discipline catalogue. ([blog.cleancoder.com — Solid Relevance](https://blog.cleancoder.com/uncle-bob/2020/10/18/Solid-Relevance.html).)

This reference is for the **Principal Engineer** and the **Work Checker**. It lists, per principle: the one-line definition, the **smell in a code-review context** (what flags a violation), and the **fix** (what the PE does about it). Don't apply SOLID dogmatically — apply it when it earns its keep. Three similar lines is better than a premature abstraction.

## S — Single Responsibility Principle

**Definition.** *"Each software module should have one and only one reason to change."* — Martin: ["This principle is about people."](https://blog.cleancoder.com/uncle-bob/2014/05/08/SingleReponsibilityPrinciple.html) Different actors (CFO/COO/CTO) must not share a module.

**Smell:**
- A class touched by every PR.
- Mixed persistence + business logic + formatting in one class.
- A function with internal headings ("now do the validation", "now do the API call", "now format the result").

**Fix:**
- Extract collaborators along axes of change.
- One class per actor — even if the resulting classes are small.

## O — Open/Closed Principle

**Definition.** Open for extension, closed for modification.

**Smell:**
- `switch` / `if`-ladder on a type tag (`if (kind === "credit") ... else if (kind === "debit") ...`).
- Modifying core code to add a variant.

**Fix:**
- Polymorphism. Each variant is a class that implements the same interface; the core calls the interface.
- Strategy / Plugin patterns when the variants are pluggable.

Martin: *"separate abstract concepts from detailed concepts."*

## L — Liskov Substitution Principle

**Definition.** Subtypes must be substitutable for their base types.

**Smell:**
- A subclass throws `NotImplementedException` / `UnsupportedOperationException`.
- A subclass strengthens preconditions (rejects inputs the base would accept).
- A subclass weakens postconditions (returns less than the base contract promises).

**Fix:**
- Split the type hierarchy — if `LightCruiser` can't `doScience()`, then `Ship` was wrong; split into `MilitaryShip` and `ScienceShip`.
- Or invert the relationship — use composition instead of inheritance.

## I — Interface Segregation Principle

**Definition.** Clients should not be forced to depend on methods they do not use.

**Smell:**
- A "fat" interface with 20 methods; implementers only need 3.
- `throw new NotImplementedError("not applicable for this implementation")` in a concrete class.

**Fix:**
- Split the interface by client role. `Readable`, `Writable`, `Closable` are separate; a class implements as many as it needs.

ISP and LSP link: *"When an interface is bloated… developers create workarounds like throwing `NotImplementedException()`, which turns an ISP violation into an LSP violation."* ([codesoapbox.dev — ISP](https://codesoapbox.dev/solid-principles-4-the-interface-segregation-principle/).)

## D — Dependency Inversion Principle

**Definition.** *"We do not want our high level business rules depending upon low level details."* (Martin, Solid Relevance.)

**Smell:**
- Domain / use-case code imports the ORM, HTTP client, file system, or environment directly.
- Business logic constructed inline with infrastructure constructors.

**Fix:**
- Define a **port** (interface) owned by the domain.
- The infrastructure provides an **adapter** that implements the port.
- Wire them together at the composition root — main / container / DI framework.

The result: the domain layer doesn't know what database or HTTP client it's running against. Test by stubbing the port. Swap the adapter without touching the domain.

## Anti-patterns the Work Checker flags

- **Over-application.** SOLID applied to a 50-line script with two functions. Don't add an interface for a single implementation. Don't extract a class for one method.
- **Premature abstraction.** Three uses of similar code is the trigger to consider extraction; two uses is too early.
- **Inheritance hierarchies > 2 deep without an LSP justification.** Almost always a sign of over-modelling.
- **Dependency injection of every class.** DI is for crossing the domain/infrastructure boundary; not every helper needs to be injected.

## When to wear which hat

This reference combines with `sdlc-pitfalls.md`'s **Two Hats** rule:

- If the PE notices a SOLID violation while adding a feature → put on the refactor hat, fix the violation in **its own commit**, push the commit, then put on the feature hat and add the feature in the **next commit**.
- If the violation is too big to fix in a quick refactor (e.g., would touch 30 files), **don't fix it now**. Open a tracking issue and add a brief note in the PR description's "Out of scope / follow-ups" section.

The discipline is: SOLID is a tool, not a religion. Apply it when the violation is biting *this* task; flag it for later when it isn't.

## Sources

- Martin, *Solid Relevance* — https://blog.cleancoder.com/uncle-bob/2020/10/18/Solid-Relevance.html
- Martin, *Single Responsibility Principle* — https://blog.cleancoder.com/uncle-bob/2014/05/08/SingleReponsibilityPrinciple.html
- *Interface Segregation Principle* — https://codesoapbox.dev/solid-principles-4-the-interface-segregation-principle/
