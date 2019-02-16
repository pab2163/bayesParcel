data {
  int<lower=0> N;                       // number of ROIs x observations (subjs x waves)
  int<lower=0> N_roi;                   // number of ROIs
  int<lower=0> N_subj;                  // number of subjects
  real cope[N];                         // estimated effects for each observation of roi
  int<lower=1, upper=N_roi> roi[N];     // ROI ID of each observation
  int<lower=1, upper=N_subj> subj[N];   // subject ID of each observation
  real<lower=0> varcope[N];             // s.e. of effect estimates
}
parameters {
  real alpha;               // intercept
  real<lower=0> tau_roi;    // SD of hyper-distribution of eta_roi
  real<lower=0> tau_subj;   // SD of hyper-distribution of eta_subj
  vector[N_roi] eta_roi;    // centered parameterization of roi-specific effect estimate
  vector[N_subj] eta_subj;  // centered parameterization of roi-specific effect estimate
}
model {
  // priors make the world go round
  alpha ~ normal(0, 1);
  tau_roi ~ normal(0, 1);
  tau_subj ~ normal(0, 1);
  eta_roi ~ normal(0, 1);
  eta_subj ~ normal(0, 1);
  // completely pooled across observations here
  cope ~ normal(alpha + tau_roi * eta_roi[roi] + tau_subj * eta_subj[subj], varcope);
}
generated quantities {
  vector[N_roi] theta_roi = alpha + tau_roi * eta_roi;
  vector[N_subj] theta_subj = alpha + tau_subj * eta_subj;
  
  vector [N] rep_cope; // Create data replicates

  for (i in 1:N)
    rep_cope[i] = normal_rng(alpha + tau_roi * eta_roi[roi][i] + tau_subj * eta_subj[subj][i], varcope[i]);
}
