data {
  real beta_0;                          // middle mixture center
  int<lower=0> N;                       // number of ROIs x observations (subjs x waves)
  int<lower=0> N_roi;                   // number of ROIs
  int<lower=0> N_subj;                  // number of subjects
  real cope[N];                         // estimated effects for each observation of roi
  int<lower=1, upper=N_roi> roi[N];     // ROI ID of each observation
  int<lower=1, upper=N_subj> subj[N];   // subject ID of each observation
  real<lower=0> varcope[N];             // s.e. of effect estimates
}
parameters {
  simplex[3] phi;           // mixing proportions
  real<upper=0> beta_neg;   // center of negative mixture component
  real<lower=0> beta_pos;   // center of positive mixture component
  real<lower=0> tau_roi;    // SD of hyper-distribution of eta_roi
  real<lower=0> tau_subj;   // SD of hyper-distribution of eta_subj
  matrix[N_roi, 3] eta_roi; // centered parameterization of roi-specific effect estimate
  vector[N_subj] eta_subj;  // centered parameterization of roi-specific effect estimate
}
transformed parameters {
  /* hard coding 3 mixture components
  kind of hacky, but this was the easiest way we figured out */
  vector[3] beta;
  beta[1] = beta_neg;
  beta[2] = beta_0;
  beta[3] = beta_pos;
}
model {
  vector[3] log_phi = log(phi);  // cache log calculation
  
  // weakly informative prior for the two estimated betas
  beta_neg ~ normal(0, 5);
  beta_pos ~ normal(0, 5);
  
  // wip for taus
  tau_roi ~ normal(0, 1);
  tau_subj ~ normal(0, 1);
  
  // wip for etas
  for (k in 1:3) {
    eta_roi[, k] ~ normal(0, 1);
  }
  
  eta_subj ~ normal(0, 1);
  
  // likelihood stuff
  for (n in 1:N) {
    vector[3] lps = log_phi;
    for (k in 1:3)
      lps[k] += normal_lpdf(cope[n] | beta[k] + tau_roi * eta_roi[roi[n], k] + tau_subj * eta_subj[subj[n]], varcope[n]);
    target += log_sum_exp(lps);
  }
}
generated quantities {
  // generated thetas, one for each mixture component
  matrix[N_roi, 3] theta_roi;
  for (k in 1:3) {
    theta_roi[, k] = beta[k] + tau_roi * eta_roi[, k];
  }
}
