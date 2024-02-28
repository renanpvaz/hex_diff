# HexDiff

Tool that diffs changes accross different hex package versions.

## Functionality

https://mermaid.live/edit#pako:eNplUstugzAQ_JXVHnqixEAgYKmpIrVqe6hUKeml4uLiDaAATowdJY3y74U8kNr4tB7NzI7Xe8BMSUKOLW0sNRk9lSLXok4b6M5nSxrup1MoaCfL5ZJfCyiMWauyVQ1sPZe5DLa-67veWXYl9cpX2sHs443Dy_MCRmuRrURO7ePmYXA4ay68v90udJBkRFm1_90hL01hv91M1SOSudU5VaPBl0NWULZS1gw-rbI6o9uQQ8NKCQmz-QLuQNsGevCW3U-ly6bLxkDvrqm1lenSpee3oIM16VqUspvroYdSNAXVlCLvSin0KsW0OXY8YY2a75sMudGWHLRrKcz1D5AvRdV26Fo0X0rVV1J3RX7AHfIwdJk_8ZKAReM4nPhR6OAeecDciAVB4E-SiMWBF0-ODv6cHJgbe2EQjH3G4jBhUZI4SLI0Sr-f9-C0Dsdf7S-puw

- [ ] Compare changes accross two different versions of a package
- [ ] Audit package usage
- [ ] Suggest next version for package

## TODO

- [ ] Test coverage for core
- [ ] Type specs
- [ ] Resolve package names through hex
- [ ] Resolve package versions through hex
- [ ] Check for installed dependency
- [ ] Cache cloned packages
- [ ] Exclude "internal" modules (@moduledoc false)
- [ ] Mix task

### Diffing

- [ ] Track typespecs or infer
- [ ] Multiple function heads/guards
- [ ] Added/Removed modules
- [ ] Macros

## Resources 

https://github.com/hexpm/hex/blob/v2.0.6/lib/hex/api/package.ex
https://github.com/elixir-lang/elixir/blob/v1.16.1/lib/mix/lib/mix/scm/git.ex
https://hexdocs.pm/sourceror/Sourceror.Zipper.html#find/3

