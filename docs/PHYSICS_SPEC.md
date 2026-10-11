# FlameSense — Physics Reference Model Specification

**Status:** Draft — awaiting [SCI] sign-off at the bottom of this page.

The physics model is a **reference check** for the ML predictions, not the
product. It must stay simple, sourced, and honest about where it does not
apply. All numbers come from `data/manual/physics_params.json`; null values
are reported as missing and the corresponding prediction returns "unavailable"
— never a guessed number.

---

## 1. Equations

### 1.1 Thermally thin opposed-flow flame spread — de Ris (1969)

$$
V_f = \frac{\pi}{4} \cdot \frac{\lambda_g \cdot (T_f - T_v)}
        {\rho_s \cdot c_s \cdot \tau \cdot (T_v - T_\infty)}
$$

| Symbol | Meaning | Unit |
|---|---|---|
| $V_f$ | Flame spread rate | m/s (converted to mm/s by ×1000) |
| $\lambda_g$ | Gas thermal conductivity | W/m·K |
| $T_f$ | Flame temperature, linear interpolation in O₂ from `flame_temp_vs_o2` | K |
| $T_v$ | Pyrolysis / vaporization temperature | K |
| $T_\infty$ | Ambient temperature | K |
| $\rho_s$ | Fuel density | kg/m³ |
| $c_s$ | Fuel specific heat | J/(kg·K) |
| $\tau$ | Fuel **half**-thickness | m |

**Valid for:** `fuel_class = thin_solid` and `flow_direction = opposed`
(quiescent microgravity counts as approximately opposed). Outside that regime
→ `not_applicable`.

### 1.2 Characteristic buoyant velocity

$$
U_b = \left( \frac{g \cdot \alpha_g \cdot (T_f - T_\infty)}{T_\infty} \right)^{1/3},
\qquad g = \text{gravity\_g} \times 9.80665
$$

| Symbol | Meaning | Unit |
|---|---|---|
| $U_b$ | Buoyant velocity | m/s |
| $\alpha_g$ | Gas thermal diffusivity | m²/s |
| $T_f$ | Flame temperature (evaluated at O₂ = 0.21 for the characteristic value) | K |
| $T_\infty$ | Ambient temperature | K |
| $g$ | Gravitational acceleration | m/s² |

Effective flow shown in the Lab / Map axis note:

$$
U_{eff} = \sqrt{U_{forced}^2 + U_b^2}
$$

This is **explanation only** and does not change the de Ris spread rate.

### 1.3 Known limitation (UI copy)

> The thin-fuel formula ignores finite-rate chemistry and radiation, so it
> over-predicts spread near extinction (very low flow in microgravity, or
> low oxygen). The ML model learns that region from data.

---

## 2. Parameter values (source of truth: `data/manual/physics_params.json`)

Values marked ⏳ are **pending [SCI]** — the model returns "unavailable" until
they are filled. Sources must be non-empty for every value.

### 2.1 Gas

| Parameter | Value | Unit | Source |
|---|---|---|---|
| `gas.lambda_w_mk` (λ_g) | ⏳ null | W/m·K | ⏳ |
| `gas.alpha_m2_s` (α_g) | ⏳ null | m²/s | ⏳ |
| `gas.t_inf_k` (T_∞) | ⏳ null | K | ⏳ |

### 2.2 Fuels (one row per fuel name as it appears in the data)

| Fuel | ρ_s (kg/m³) | c_s (J/kg·K) | T_v (K) | τ (m) | Source |
|---|---|---|---|---|---|
| `cotton-fiberglass` | ⏳ null | ⏳ null | ⏳ null | ⏳ null | ⏳ |

> τ is the fuel **half**-thickness in metres (`half_thickness_m`).

### 2.3 Flame temperature vs O₂

| O₂ (mole fraction) | T_f (K) |
|---|---|
| 0.21 | ⏳ null |
| 0.30 | ⏳ null |

Source: ⏳

### 2.4 Buoyant velocity

| Parameter | Value | Source |
|---|---|---|
| `buoyant_velocity.enabled` | true | ⏳ |

---

## 3. Applicability rules

`applicability(row)` returns:

| Value | Condition |
|---|---|
| `ok` | `fuel_class = thin_solid` AND `flow_direction ∈ {opposed, quiescent}`, not near-extinction |
| `near_extinction_warning` | As `ok`, but **O₂ < 0.15** OR (microgravity `gravity_g < 0.01` AND forced flow `< 5 mm/s`) — see TODO(Q-1) in QUESTIONS.md |
| `not_applicable` | Anything else (thick solid, droplet, gas jet, concurrent flow) |

---

## 4. Sign-off

- [ ] Verified by science lead — name/date